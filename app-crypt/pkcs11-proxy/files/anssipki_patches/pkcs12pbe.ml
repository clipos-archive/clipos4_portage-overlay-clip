(************************* MIT License HEADER ************************************
    Copyright ANSSI (2015)
    Contributors : Ryad BENADJILA [clipos@ssi.gouv.fr]

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

    Except as contained in this notice, the name(s) of the above copyright holders
    shall not be used in advertising or otherwise to promote the sale, use or other
    dealings in this Software without prior written authorization.

************************** MIT License HEADER ***********************************)

(**** PKCS#12 PBE function ****)

(* Computes the upper bound of a/b *)
let upper_bound a b =
  if a = 0 then
    (1)
  else
    if a mod b = 0 then
      (a/b)
    else
      ((a/b)+1)

(* Addition of two big blocks of arbitrary size            *)
(* in big endian (first byte is the most significant byte) *)
(* The result is trucated to the biggest block             *)
let big_int_add_fixed_block a b =
   (* Expand the smallest block *)
   let a = (
     if (Array.length a) < (Array.length b) then
       (Array.concat [ Array.make ((Array.length b)-(Array.length a)) (Char.chr 0); a ])
     else
       (a)
  ) in
  let b = (
     if (Array.length b) < (Array.length a) then
       (Array.concat [ Array.make ((Array.length a)-(Array.length b)) (Char.chr 0); b ])
     else
       (b)
  ) in
  let carry = ref 0 in
  let result = ref (Array.make (Array.length a) (Char.chr 0)) in
  for i = (Array.length a - 1) downto 0 do
    if (Char.code a.(i)) <> 0xff then
    begin
      let tmp = (Char.code a.(i)) + !carry in
      !result.(i) <- Char.chr (((Char.code b.(i)) + tmp) land 0xff);
      if !result.(i) < b.(i) then
        carry := 1
      else
        carry := 0
    end
    else
    begin
      if (Char.code b.(i)) <> 0xff then
        let tmp = (Char.code b.(i)) + !carry in
        !result.(i) <- Char.chr (((Char.code a.(i)) + tmp) land 0xff);
        if !result.(i) < a.(i) then
          carry := 1
        else
          carry := 0
      else
        if !carry = 1 then
          !result.(i) <- (Char.chr 0xff)
        else
          !result.(i) <- (Char.chr 0xfe);
          carry := 1
    end
  done;
  (!result)


let pkcs12pbe hashfunction blocksize password salt iter dklen id =
  (* Get the output length of the prf *)
  let hlen = try Array.length (hashfunction [||])
    with _ -> let error = Printf.sprintf "Fail when doing PKCS#12 PBE: given hash funtion fails ...\n" in failwith error;
  in
  if hlen = 0 then
    let error = Printf.sprintf "Fail when doing PKCS#12 PBE: given hash funtion does have an empty output\n" in failwith error;
  else
    if (id = 0) || (id > 3) then
      let error = Printf.sprintf "Fail when doing PKCS#12 PBE: given id %d is not valid\n" id in failwith error;
    else
      (* Expand the password in two bytes *)
      let expanded_password = Array.make (2*(Array.length password)) (Char.chr 0) in
      let expanded_password = Array.mapi (
        fun i a ->
          if (i mod 2) = 0 then
            (Char.chr 0)
          else
            (password.(i/2))
      ) expanded_password in
      let expanded_password = Array.concat [ expanded_password; [| Char.chr 0; Char.chr 0 |] ] in
      (* Construct the diversifier *)
      let d = Array.make blocksize (Char.chr id) in
      (* Concatenate the salt *)
      let s = Array.make (blocksize * (upper_bound (Array.length salt) blocksize)) (Char.chr 0) in
      let s = Array.mapi (
        fun index a -> salt.(index mod (Array.length salt))
      ) s in
      (* Concatenate the password *)
      let p = Array.make (blocksize * (upper_bound (Array.length expanded_password) blocksize)) (Char.chr 0) in
      let p = Array.mapi (
        fun index a -> expanded_password.(index mod (Array.length expanded_password))
      ) p in
      let i = ref (Array.concat [ s; p ]) in
      let nblocks = upper_bound dklen hlen in
      let array_list = ref (Array.create nblocks [||]) in
      for index = 0 to nblocks-1 do
        !array_list.(index) <- Array.concat [ d; !i ];
        for index_hash = 1 to iter do
          !array_list.(index) <- hashfunction !array_list.(index);
        done;
        let b = Array.make blocksize (Char.chr 0) in
        let b = Array.mapi (
          fun b_index a -> (!array_list.(index).(b_index mod hlen))
        ) b in
        (* Compute new i with a blocksize addition *)
        let new_i = ref [||] in
        for index_i = 0 to ((Array.length s) + (Array.length p) - 1)/blocksize do
          let extract_i = Array.sub !i ((index_i)*blocksize) blocksize in
          let new_i_block_value = big_int_add_fixed_block [| Char.chr 1 |] extract_i in
          let new_i_block_value = big_int_add_fixed_block new_i_block_value b in
          new_i := Array.concat [ !new_i; new_i_block_value ];
        done;
        (* Update I *)
        i := !new_i;
      done;
      (* Concatenate the results *)
      let a = Array.concat (Array.to_list !array_list) in
      (* Extract the first dklen bytes which will form the result *)
      (Array.sub a 0 dklen)


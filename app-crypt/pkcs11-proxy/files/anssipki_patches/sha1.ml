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

(*** SHA-1 function ***)

type sha1_ctx = {
  mutable total  : int64;
  mutable state  : int32 array;
  mutable buffer : char array;
}

(* WARNING: this helper is for little endian architectures *)
(* FIXME: get an endian neutral helper                     *)
let char_array_to_int32 input =
  if Array.length input <> 4 then
    let error = Printf.sprintf "char_array_to_int32 size error: %d instead of 4 bytes\n" (Array.length input) in failwith error;
  else
    let output = ref (Int32.of_string "0") in
    for i = 0 to 3 do
      output := Int32.logxor (Int32.shift_left (Int32.of_int (Char.code input.(i))) (8*(3-i))) !output;
    done;
    (!output)

(* WARNING: this helper is for little endian architectures *)
(* FIXME: get an endian neutral helper                     *)
let int32_to_char_array input =
  let output = Array.make 4 (Char.chr 0) in
  for i = 0 to 3 do
    output.(i) <- Char.chr ((Int32.to_int (Int32.shift_right_logical input (8*(3-i)))) land 0xff);
  done;
  (output)


(* WARNING: this helper is for little endian architectures *)
(* FIXME: get an endian neutral helper                     *)
let int64_to_char_array input =
  let output = Array.make 8 (Char.chr 0) in
  for i = 0 to 7 do
    output.(i) <- Char.chr ((Int64.to_int (Int64.shift_right_logical input (8*(7-i)))) land 0xff);
  done;
  (output)

(* WARNING: this helper is for little endian architectures *)
(* FIXME: get an endian neutral helper                     *)
let int64_to_char_array input =
  let output = Array.make 8 (Char.chr 0) in
  for i = 0 to 7 do
    output.(i) <- Char.chr ((Int64.to_int (Int64.shift_right_logical input (8*(7-i)))) land 0xff);
  done;
  (output)

let leftrotate32 a rot =
  let tmp1 = Int32.shift_left a rot in
  let tmp2 = Int32.shift_right_logical a (32-rot) in
  (Int32.logxor tmp1 tmp2)

(* SHA-1 init *)
let sha1_init ctx =
  ctx.total <- Int64.of_string "0";
  ctx.state <- Array.make 5 (Int32.of_string "0");
  ctx.state.(0) <- Int32.of_string "0x67452301";
  ctx.state.(1) <- Int32.of_string "0xEFCDAB89";
  ctx.state.(2) <- Int32.of_string "0x98BADCFE";
  ctx.state.(3) <- Int32.of_string "0x10325476";
  ctx.state.(4) <- Int32.of_string "0xC3D2E1F0";
  ctx.buffer <- [||];
  (ctx)

let sha1_proceed_chunk ctx chunk =
  (* Extend the chunk *)
  if Array.length chunk <> 64 then
    let error = Printf.sprintf "SHA-1 chunk size error: %d instead of 64 bytes\n" (Array.length chunk) in failwith error;
  else
    let w = Array.make 80 (Int32.of_string "0") in
    for i = 0 to 15 do
      (* First 16 elements are 16 32-bit integers from the 64 bytes *)
      w.(i) <- char_array_to_int32 (Array.sub chunk (4*i) 4);
    done;
    for i = 16 to 79 do
      w.(i) <- leftrotate32 (Int32.logxor (Int32.logxor w.(i-3) w.(i-8)) (Int32.logxor w.(i-14) w.(i-16))) 1;
    done;
    let (a, b, c, d, e) = (ref ctx.state.(0), ref ctx.state.(1), ref ctx.state.(2), ref ctx.state.(3), ref ctx.state.(4)) in
    (* Proceed the core SHA-1 *)
    for i = 0 to 79 do
      let (f, k) = (match i/20 with
          0 -> (Int32.logor (Int32.logand !b !c) (Int32.logand (Int32.lognot !b) !d), Int32.of_string "0x5A827999")
        | 1 -> (Int32.logxor (Int32.logxor !b !c) !d, Int32.of_string "0x6ED9EBA1")
        | 2 -> (Int32.logor (Int32.logor (Int32.logand !b !c) (Int32.logand !b !d)) (Int32.logand !c !d) , Int32.of_string "0x8F1BBCDC")
        | 3 -> (Int32.logxor (Int32.logxor !b !c) !d, Int32.of_string "0xCA62C1D6")
        | _ -> let error = Printf.sprintf "SHA-1 core loop overflow\n" in failwith error;
      ) in
      let temp = Int32.add (Int32.add (Int32.add (Int32.add (leftrotate32 !a 5) f) !e) k) w.(i) in
      e := !d;
      d := !c;
      c := leftrotate32 !b 30;
      b := !a;
      a := temp;
    done;
    ctx.state.(0) <- Int32.add ctx.state.(0) !a;
    ctx.state.(1) <- Int32.add ctx.state.(1) !b;
    ctx.state.(2) <- Int32.add ctx.state.(2) !c;
    ctx.state.(3) <- Int32.add ctx.state.(3) !d;
    ctx.state.(4) <- Int32.add ctx.state.(4) !e;
    ()
(* SHA-1 update *)
let sha1_update ctx message =
  (* Get the remaining message of the previous update *)
  let message = Array.concat [ ctx.buffer; message ] in
  (* Truncate the current message into chunks of 64 bytes *)
  for i = 0 to (Array.length message/64)-1 do
    ctx.total <- Int64.add ctx.total (Int64.of_int 512);
    let chunk = Array.sub message (64*i) 64 in
    sha1_proceed_chunk ctx chunk;
  done;
  (* Take care of the possible last block by adding it to the working buffer *)
  if (Array.length message) mod 64 <> 0 then
    ctx.buffer <- Array.sub message ((Array.length message/64)*64) ((Array.length message) mod 64);
  (ctx)

(* SHA-1 Final *)
let sha1_final ctx message =
  (* Get the remaining message of the previous update *)
  let message = Array.concat [ ctx.buffer; message ] in
  ctx.total <- Int64.add ctx.total (Int64.of_int (8 * (Array.length message)));
  (* This is the final pass, so proceed with the padding *)
  let message = Array.concat [ message; [| Char.chr 0x80 |] ] in
  let zero_pad = (
    if (Array.length message mod 64) < 56 then
      (Array.make (56 - (Array.length message mod 64)) (Char.chr 0))
    else
      (Array.make (56 + 64 - (Array.length message mod 64)) (Char.chr 0))
    ) in
  let message = Array.concat [ message; zero_pad; int64_to_char_array ctx.total ] in
  (* Proceed with the padded message *)
  for i = 0 to (Array.length message/64)-1 do
    let chunk = Array.sub message (64*i) 64 in
    sha1_proceed_chunk ctx chunk;
  done;
  (* Now output the hash value *)
  let sha1_hash_value = Array.concat [ int32_to_char_array ctx.state.(0); int32_to_char_array ctx.state.(1); int32_to_char_array ctx.state.(2); int32_to_char_array ctx.state.(3); int32_to_char_array ctx.state.(4) ] in
  (sha1_hash_value)

let sha1 message =
  let ctx = { total = Int64.of_string "0"; state = [||]; buffer = [||] } in
  let ctx = sha1_init ctx in
  let ctx = sha1_update ctx message in
  let hash = sha1_final ctx [||] in
  (hash)



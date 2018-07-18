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

(* Transform a 6 bit integer into a base64 byte *)
let base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

(* Transform a base64 integer into its index *)
let base64_decode_chars = [|
    -3; -3; -3; -3; -3; -3; -3; -3; -3; -2; -2; -3; -3; -2; -3; -3;
    -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3;
    -2; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; 62; -3; -3; -3; 63;
    52; 53; 54; 55; 56; 57; 58; 59; 60; 61; -3; -3; -3; -1; -3; -3;
    -3; 00; 01; 02; 03; 04; 05; 06; 07; 08; 09; 10; 11; 12; 13; 14;
    15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25; -3; -3; -3; -3; -3;
    -3; 26; 27; 28; 29; 30; 31; 32; 33; 34; 35; 36; 37; 38; 39; 40;
    41; 42; 43; 44; 45; 46; 47; 48; 49; 50; 51; -3; -3; -3; -3; -3;
    -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3;
    -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3;
    -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3;
    -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3;
    -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3;
    -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3;
    -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3;
    -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3; -3
                          |]

(* Base64 encoder *)
(*******************************************)
let base64_encode_three_bytes in_string =   
  (* Put the three bytes in an integer *)
  let integer = ref 0 in
  if (String.length in_string) > 0 then
    integer := !integer lxor (Char.code in_string.[0] lsl 16);
    if (String.length in_string) > 1 then
      integer := !integer lxor ((Char.code in_string.[1]) lsl 8);
      if (String.length in_string) > 2 then    
        integer := !integer lxor ((Char.code in_string.[2]));
  (* Split the integer 6 bits by 6 bits *)
  let encoded_string = ref (String.create 4) in
  for i = 0 to 3 do
    let index = (!integer lsr (6*i)) land 0x3f in
    !encoded_string.[3-i] <- base64_chars.[index];
  done;
  (* Pad with = depending on the size *)
  match (String.length in_string) with
     1 -> 
     !encoded_string.[2] <- '=';
     !encoded_string.[3] <- '=';
     (!encoded_string)
   | 2 ->
     !encoded_string.[3] <- '=';
     (!encoded_string)
   | 3 ->
     (!encoded_string)
   | _ ->
     ("")

let base64_encode in_string = 
  (* Process the string 3 bytes per 3 bytes *)
  let i = ref 0 in
  let encoded_string = ref "" in
  while !i < (String.length in_string) do
    let extract = (if ((String.length in_string) - !i) >= 3 then 3 else ((String.length in_string) - !i)) in
    encoded_string := !encoded_string ^ (base64_encode_three_bytes (String.sub in_string !i extract));
    i := !i + 3;
  done;
  (!encoded_string)


(* Base64 decoder *)
(*******************************************)
let base64_decode_four_bytes in_string =
  (* Store the reverse index bytes in an integer *)
  let integer = ref 0 in
  let index = ref 0 in
  for i = 0 to (String.length in_string - 1) do
    let to_store = base64_decode_chars.(Char.code in_string.[i]) in
    (match to_store with
       (-1 | -2 | -3) -> (* Drop the char *) ();   
       | _ ->        
         integer := !integer lxor (to_store lsl (6*(3 - !index)));
         index := !index + 1;
    );
  done;
  if !index = 0 then
    ("")
  else
    let _ = index := !index - 1 in
    (* Split the integer 8 bits by 8 bits *)
    let decoded_string = ref (String.create !index) in
    for i = 0 to (!index-1) do
      let byte = (!integer lsr (8*(i+(3 - !index)))) land 0xff in
      !decoded_string.[(!index-1)-i] <- Char.chr byte;
    done;
    (!decoded_string)

let base64_decode in_string = 
  (* Process the string 4 bytes per 4 bytes *)
  let i = ref 0 in
  let decoded_string = ref "" in
  while !i < (String.length in_string) do
    let extract = (if ((String.length in_string) - !i) >= 4 then 4 else ((String.length in_string) - !i)) in
    decoded_string := !decoded_string ^ (base64_decode_four_bytes (String.sub in_string !i extract));
    i := !i + 4;
  done;
  (!decoded_string)

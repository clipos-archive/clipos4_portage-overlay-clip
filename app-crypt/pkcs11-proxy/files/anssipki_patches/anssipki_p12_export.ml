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

(***********************************************************************)
(* The patch exporting a p12 through C_WrapKey                         *)

(* Include the PKCS12 PBE cryptographic helpers here *)
INCLUDE "anssipki_patches/sha1.ml"
INCLUDE "anssipki_patches/pkcs12pbe.ml"

(* Wipe helpers *)
(* FIXME: this wiping method is not very robust and safe *)
let wipe_string s = String.fill s 0 (String.length s) '\000'
let wipe_array a = Array.fill a 0 (Array.length a) (Char.chr 0)

(* Marshalling helpers                          *)
(* Marshal a native int to an 64-bit char array *)
(* We do not have to deal with endianness since we are sure to reuse this value *)
let marshal_native_int input = 
  let int64_t = Int64.of_nativeint input in
  let output = Array.make 8 (Char.chr 0) in
  for i=0 to 7 do
    output.(i) <- Char.chr ((Int64.to_int (Int64.shift_right_logical int64_t (8*(7-i)))) land 0xff);
  done;
  (output) 
(* Marshal a char array with its prepending size as a 64-bit array *)
let marshal_char_array char_array = 
  let size_array = marshal_native_int (Nativeint.of_int (Array.length char_array)) in
  (Array.concat [ size_array; char_array ])

(* The hash table that keeps track of handles and  *)
let anssipki_p12_export_hash_tbl_wrap : (Pkcs11.ck_object_handle_t, bool * nativeint * char array * Pkcs11.ck_object_handle_t * Pkcs11.ck_session_handle_t) Hashtbl.t ref = ref (Hashtbl.create 0)
let anssipki_p12_export_hash_tbl_mac : (Pkcs11.ck_object_handle_t, bool * nativeint * Pkcs11.ck_session_handle_t) Hashtbl.t ref = ref (Hashtbl.create 0)

let pkcs12_PBE_SHA1_DES3_EDE_CBC = Nativeint.of_string "-1"

let match_p12_export_mechanism mech = 
  if compare mech.Pkcs11.mechanism pkcs12_PBE_SHA1_DES3_EDE_CBC = 0 then
    (true, Pkcs11.cKM_DES3_CBC_PAD, Pkcs11.cKM_SHA_1_HMAC)
  else
    (false, 0n, 0n)

let generate_iv_key_mac mech pwd salt iter = 
  if compare mech.Pkcs11.mechanism pkcs12_PBE_SHA1_DES3_EDE_CBC = 0 then
     let wrap_key = pkcs12pbe sha1 64 pwd salt iter 24 1 in
     let iv = pkcs12pbe sha1 64 pwd salt iter 8 2 in
     let mac_key = pkcs12pbe sha1 64 pwd salt iter 20 3 in
     (true, wrap_key, iv, mac_key)
  else
    (false, [||], [||], [||])

let p12_wrapping_sym_key_creation_template mech = 
  let the_key_type =  
  (if compare mech.Pkcs11.mechanism pkcs12_PBE_SHA1_DES3_EDE_CBC = 0 then
     Pkcs11.cKK_DES3
   else
     Pkcs11.cKK_GENERIC_SECRET) in
  ([|
    {Pkcs11.type_ = Pkcs11.cKA_KEY_TYPE; Pkcs11.value = Pkcs11.int_to_ulong_char_array the_key_type};
    {Pkcs11.type_ = Pkcs11.cKA_CLASS; Pkcs11.value = Pkcs11.int_to_ulong_char_array Pkcs11.cKO_SECRET_KEY};
    {Pkcs11.type_ = Pkcs11.cKA_TOKEN; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_WRAP; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
    {Pkcs11.type_ = Pkcs11.cKA_UNWRAP; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_ENCRYPT; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_DECRYPT; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_SIGN; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_VERIFY; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
(*  
    FIXME: attributes not supported by SoftHSMv2
    {Pkcs11.type_ = Pkcs11.cKA_SIGN_RECOVER; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_VERIFY_RECOVER; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE}; 
*)
    {Pkcs11.type_ = Pkcs11.cKA_SENSITIVE; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
    {Pkcs11.type_ = Pkcs11.cKA_EXTRACTABLE; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_LABEL; Pkcs11.value = Pkcs11.string_to_char_array "ANSSIPKI_TEMP_WRAP"};
  |])

let p12_mac_sym_key_creation_template mech = 
  [|
    {Pkcs11.type_ = Pkcs11.cKA_KEY_TYPE; Pkcs11.value = Pkcs11.int_to_ulong_char_array Pkcs11.cKK_GENERIC_SECRET};
    {Pkcs11.type_ = Pkcs11.cKA_CLASS; Pkcs11.value = Pkcs11.int_to_ulong_char_array Pkcs11.cKO_SECRET_KEY};
    {Pkcs11.type_ = Pkcs11.cKA_TOKEN; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_WRAP; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_UNWRAP; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_ENCRYPT; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_DECRYPT; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_SIGN; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
    {Pkcs11.type_ = Pkcs11.cKA_VERIFY; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
(*  
    FIXME: attributes not supported by SoftHSMv2
    {Pkcs11.type_ = Pkcs11.cKA_SIGN_RECOVER; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_VERIFY_RECOVER; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE}; 
*)
    {Pkcs11.type_ = Pkcs11.cKA_SENSITIVE; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
    {Pkcs11.type_ = Pkcs11.cKA_EXTRACTABLE; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_FALSE};
    {Pkcs11.type_ = Pkcs11.cKA_LABEL; Pkcs11.value = Pkcs11.string_to_char_array "ANSSIPKI_TEMP_MAC"};
  |]

let anssipki_p12_export_init fun_name arg =
  (* We block unsused functions *)
  match fun_name with
    "C_WrapKey" ->
      let (sessionh, mechanism, wrappingh, wrappedh) = deserialize arg in
      (* Does the Wrap mechanism concerns an initialized PKCS#12 export? *)
      let (found, mech_wrap, iv_wrap, wrappedh_wrap, _) = (try Hashtbl.find !anssipki_p12_export_hash_tbl_wrap wrappingh with
      Not_found -> (false, 0n, [||], 0n, Pkcs11.cK_INVALID_HANDLE)) in
      if found = true then
        (*** A key has been found: this is indeed a real C_Wrap for p12 export *)
        (* Check that the concerned key to wrap has a proper label *)
	if anssipki_check_label sessionh wrappedh = false then
          (serialize (true, (Pkcs11.cKR_OBJECT_HANDLE_INVALID, [||])))
        else
          (* We do the real C_Wrap *)
          (* We check that the asked mechanism is indeed the one asked at init *)
          if (compare mechanism.Pkcs11.mechanism mech_wrap = 0) && (compare wrappedh wrappedh_wrap = 0) then
            (* Proceed with the real C_Wrap *)
            let (ret, wrapped_key_buffer) = Backend.c_WrapKey sessionh {Pkcs11.mechanism = mech_wrap; Pkcs11.parameter = iv_wrap} wrappingh wrappedh in
            if compare ret Pkcs11.cKR_OK = 0 then
              (* Then destroy the handle *)
              let ret = Pkcs11.c_DestroyObject sessionh wrappingh in
              if compare ret Pkcs11.cKR_OK = 0 then
                (* All is OK, we return the result *)
                (serialize (true, (Pkcs11.cKR_OK, wrapped_key_buffer))) 
              else
                (* There has been an error, return a general error *)
                let s = Printf.sprintf "[User defined extensions]: error when destroying objects during PKCS#12 C_Wrap" in
                print_debug s 1;
                (serialize (true, (Pkcs11.cKR_GENERAL_ERROR, [||]))) 
            else
              (* There has been an error, return a general error *)
              let s = Printf.sprintf "[User defined extensions]: error when c_WrapKey %i" (Nativeint.to_int  ret) in
              print_debug s 1;
              (serialize (true, (Pkcs11.cKR_GENERAL_ERROR, [||]))) 
          else
            (* The two mechanisms are incompatible, return an error *)
            (serialize (true, (Pkcs11.cKR_GENERAL_ERROR, [||])))
        else
          (*** No key found to Wrap, this means we have a PKCS#12 export init *)
          (*** or a regular C_WrapKey                                         *)
          (*** Get the mechanism                                              *)
          let (check, mech_wrap, mech_mac) = match_p12_export_mechanism mechanism in
          if check = true then
            (* It is a PKCS#12 export init            *)
            (* Create the proper keys in the token    *)
            (* Get the password from external command *)
            let (ret_status, pwd, error_message) = fork_exec_command anssipki_external_pwd_handler "" anssipki_external_pwd_handler_args anssipki_external_pwd_handler_env in
            if ret_status = true then
              (* Get a random value for the salt *)
              let (ret, salt) = Backend.c_GenerateRandom sessionh 8n in
              if compare ret Pkcs11.cKR_OK <> 0 then
                (* Error when getting random from the token, fail *)
                let s = Printf.sprintf "[User defined extensions]: error during PKCS#12 export init when getting random with C_GenerateRandom" in
                let _ = print_debug s 1 in
                (serialize (true, (Pkcs11.cKR_GENERAL_ERROR, [||])))
              else
                (* Generate the IV, the private key encryption key and the HMAC key from the password *)
                let iter = 2048 in
                let (_, wrap_key, iv_wrap, mac_key) = generate_iv_key_mac mechanism (Pkcs11.string_to_char_array pwd) salt iter in
                (* We can wipe the password now *)
                let _ = wipe_string pwd in
                (* Inject the keys in the token *)
                let wrap_key_template = Array.concat [ p12_wrapping_sym_key_creation_template mechanism; [|{Pkcs11.type_ = Pkcs11.cKA_VALUE; Pkcs11.value = wrap_key}|] ] in
                let mac_key_template  = Array.concat [ p12_mac_sym_key_creation_template mechanism; [|{Pkcs11.type_ = Pkcs11.cKA_VALUE; Pkcs11.value = mac_key}|] ] in
                let (ret_wrap, wrap_key_h) = Backend.c_CreateObject sessionh wrap_key_template in
                let (ret_mac, mac_key_h)  = Backend.c_CreateObject sessionh mac_key_template in
                (* When the keys are created, we do not need the values of the keys anymore *)
                let _ = wipe_array wrap_key in
                let _ = wipe_array mac_key in
                (* If there has been an error here, trigger a general error *)
                if (compare ret_wrap Pkcs11.cKR_OK <> 0) || (compare ret_wrap Pkcs11.cKR_OK <> 0) then
                  let _ = Backend.c_DestroyObject sessionh wrap_key_h in
                  let _ = Backend.c_DestroyObject sessionh mac_key_h in
                  let s = Printf.sprintf "[User defined extensions]: error when creating objects during PKCS#12 C_Wrap" in
                  let _ = print_debug s 1 in
                  failwith s;
                else
                  (* Add them to the hash tables *)
                  let _ = Hashtbl.add !anssipki_p12_export_hash_tbl_wrap wrap_key_h (true, mech_wrap, iv_wrap, wrappedh, sessionh) in
                  let _ = Hashtbl.add !anssipki_p12_export_hash_tbl_mac mac_key_h (true, mech_mac, sessionh) in
                  (* Format the answer to send back in the buffer *)
                  (* [handle_wrapping_key (64 bits) | handle_mac_key (64-bits) | iter (64-bits) | saltlen (64-bits) | salt (saltlen)] *)
                  let wrap_key_h_marshalled  = marshal_native_int wrap_key_h in
                  let mac_key_h_marshalled = marshal_native_int mac_key_h in
                  let iter_marshalled = marshal_native_int (Nativeint.of_int iter) in
                  let salt_marshalled = marshal_char_array salt in
                  let buffer_to_return = Array.concat [ wrap_key_h_marshalled; mac_key_h_marshalled; iter_marshalled; salt_marshalled ] in
                  (serialize (true, (Pkcs11.cKR_OK, buffer_to_return)))
            else
              (* Error during the external command: log and return an error *)
              let s = Printf.sprintf "[User defined extensions]: error during PKCS#12 export init, command %s returned %s on stderr" anssipki_external_pwd_handler error_message in
              let _ = print_debug s 1 in
              (serialize (true, (Pkcs11.cKR_GENERAL_ERROR, [||]))) 
          else
            (* It is a regular C_WrapKey, passthrough to the real C_Wrap function *)
            (serialize (false, ()))
    | "C_SignInit" ->
      (* Check if we have a regular SignInit or one with an export *)
      let (sessionh, mechanism, keyh) = deserialize arg in
      (* Does the Wrap mechanism concerns an initialized PKCS#12 export? *)
      let (found, mech_mac, _) = (try Hashtbl.find !anssipki_p12_export_hash_tbl_mac keyh with
      Not_found -> (false, 0n, Pkcs11.cK_INVALID_HANDLE)) in
      if found = true then
        (* We have found a mac key, do the stuff *)
        let ret = Backend.c_SignInit sessionh {Pkcs11.mechanism = mech_mac; Pkcs11.parameter = [||]} keyh in
        if compare ret Pkcs11.cKR_OK = 0 then
          (* Then destroy the handle *)
          let ret = Backend.c_DestroyObject sessionh keyh in
          if compare ret Pkcs11.cKR_OK = 0 then
            (serialize (true, (Pkcs11.cKR_OK)))            
          else
            (* There has been an error, return a general error *)
            let s = Printf.sprintf "[User defined extensions]: error when destroying objects during PKCS#12 C_SignInit" in
            let _ = print_debug s 1 in
            failwith s;
        else
          (* There has been an error, return a general error *)
          let s = Printf.sprintf "[User defined extensions]: error when signing during PKCS#12 C_SignInit" in
          let _ = print_debug s 1 in
          (serialize (true, (Pkcs11.cKR_GENERAL_ERROR))) 
      else
        (* Passthrough, this is a regular SignInit *)
        (serialize (false, ()))
    | ("C_CloseSession" | "C_CloseAllSessions") ->
      (* Session is closing, destroy and purge our objects *)
      (* Iterate through the hash tables *)
      let _ = Hashtbl.iter (
        fun wrap_h (_, _, _, _, session_h) -> 
        let _ = Backend.c_DestroyObject session_h wrap_h in ();
      ) !anssipki_p12_export_hash_tbl_wrap in
      let _ = Hashtbl.iter (
        fun mac_h (_, _, session_h) -> 
        let _ = Backend.c_DestroyObject session_h mac_h in ();
      ) !anssipki_p12_export_hash_tbl_mac in
      (serialize (false, ()))
    (* Default if we are in a non concerned function is to passthrough *)
    | _ -> (serialize (false, ()))

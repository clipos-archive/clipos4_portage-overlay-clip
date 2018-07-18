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
(* The patch preventing using PKCS#11 objects other than for signatrure*)
(* and verification functions                                          *)
(* as well as using the external X509 validator                        *)

(* Base64 needed to decode information given by the ANSSIPKI validator *)
INCLUDE "anssipki_patches/base64.ml"
INCLUDE "anssipki_patches/oids.ml"
INCLUDE "anssipki_patches/asn1.ml"

(* The attributes we do not want to be set for ANSSIPKI objects *)
let anssipki_fobidden_attributes = [|
                     {Pkcs11.type_ = Pkcs11.cKA_WRAP; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
                     {Pkcs11.type_ = Pkcs11.cKA_UNWRAP; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
                     {Pkcs11.type_ = Pkcs11.cKA_ENCRYPT; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
                     {Pkcs11.type_ = Pkcs11.cKA_DECRYPT; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
                     {Pkcs11.type_ = Pkcs11.cKA_SIGN_RECOVER; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
                     {Pkcs11.type_ = Pkcs11.cKA_VERIFY_RECOVER; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
                                    |]

let anssipki_x509_cert_creation_basic_template = [|
                     {Pkcs11.type_ = Pkcs11.cKA_TOKEN; Pkcs11.value = Pkcs11.bool_to_char_array Pkcs11.cK_TRUE};
                     {Pkcs11.type_ = Pkcs11.cKA_LABEL; Pkcs11.value = Pkcs11.string_to_char_array anssipki_cert_label};
                     {Pkcs11.type_ = Pkcs11.cKA_CLASS; Pkcs11.value = Pkcs11.int_to_ulong_char_array Pkcs11.cKO_CERTIFICATE};
                     {Pkcs11.type_ = Pkcs11.cKA_CERTIFICATE_TYPE; Pkcs11.value = Pkcs11.int_to_ulong_char_array Pkcs11.cKC_X_509};
                                                  |]

let check_anssipki_fobidden_attribute the_attribute =
  let check = Array.fold_left (
    fun curr_check attrib ->
      if compare attrib.Pkcs11.type_ the_attribute.Pkcs11.type_ = 0 then
        if compare attrib.Pkcs11.value (Pkcs11.bool_to_char_array Pkcs11.cK_TRUE) = 0 then
          (* Check *)
          if compare the_attribute.Pkcs11.value (Pkcs11.bool_to_char_array Pkcs11.cK_FALSE) = 0 then
            (curr_check || false)
          else
            (curr_check || true)
        else
          (* Check *)
          if compare the_attribute.Pkcs11.value (Pkcs11.bool_to_char_array Pkcs11.cK_FALSE) = 0 then
            (curr_check || true)
          else
            (curr_check || false)
      else
        (curr_check || false)
  ) false anssipki_fobidden_attributes in
  (check)

let check_anssipki_fobidden_attributes attributes_array =
  let check = Array.fold_left (
    fun curr_check attrib ->
      (curr_check || (check_anssipki_fobidden_attribute attrib))
  ) false attributes_array in
  (check)

type anssipki_validate_x509_types =
  | X509 of string * string * string
  | CRL
  | Other

(* ANSSI PKI X509 validator *)
let anssipki_validate_x509 data =
  (* Launch the external command and get the result *)
  let (check, out_stdout, out_stderr) = fork_exec_command anssipki_external_x509_validator "" anssipki_external_x509_validator_args anssipki_external_x509_validator_env in
  match check with
    | true ->
      (* Check if we have a X509 or a CRL *)
      let output = (
        match out_stdout with
          | "CRL\n" -> CRL
          | _ ->
            if check_regexp "X509\n.*" out_stdout = true then
              if String.length out_stdout = 5 then
                (X509("", "", ""))
              else
                (* Get the subject/modulus/exponent base64 DER *)
                let subject_modulus_exponent_base64 = String.sub out_stdout 4 ((String.length out_stdout)-5) in
                (* Split the string with the CR *)
                let string_list = Str.split (Str.regexp "\n") subject_modulus_exponent_base64 in
                if List.length string_list <> 3 then
                  let s = Printf.sprintf "[User defined extensions]: X509 validator returned an X509 with malformed base64 output" in
                  let _ = print_debug s 1 in
                  failwith(s);
                else
                  let [ subject_base64; modulus_base64; exponent_base64 ] = string_list in
                  (* Extract the DER value from base64 *)
                  (X509(base64_decode subject_base64, base64_decode modulus_base64, base64_decode exponent_base64))
            else
              (Other)
      ) in
      (true, output)
    (* Any other is considered as an error *)
    | _ ->
      let s = Printf.sprintf "[User defined extensions]: X509 validator returned %s as error" out_stderr in
      let _ = print_debug s 1 in
      (false, Other)


let normalize_big_int big_int =
  if String.length big_int > 0 then
    if big_int.[0] = (Char.chr 0x0) then
      String.sub big_int 1 (String.length big_int - 1)
    else
      big_int
  else
    big_int


(* We define the TBS+sinature ASN1 structure *)
let x509_data_scheme_c data signature_data oid_name =
  let algo_oid_asn1 = build_asn1_representation (
    Sequence_C("", [
      OID_C(oid_name_to_asn1_string oid_name OID);
      Null_C;
    ])) "" in
  let signature_asn1 = build_asn1_representation (
    Bitstring_C(bitstring_to_asn1_string signature_data (8*(String.length signature_data)) Bitstring)
  ) "" in
  (Sequence_C(data ^ algo_oid_asn1 ^ signature_asn1, []))

(* Method to get the ID of a certificate from its modulus and exponent *)
let get_id_of_x509_from_public_key sessionh modulus_der exponent_der =
  (* Fetch all the public keys *)
  let public_key_search_template = [|
                     {Pkcs11.type_ = Pkcs11.cKA_CLASS; Pkcs11.value = Pkcs11.int_to_ulong_char_array Pkcs11.cKO_PUBLIC_KEY};
                     {Pkcs11.type_ = Pkcs11.cKA_LABEL; Pkcs11.value = Pkcs11.string_to_char_array "ANSSIPKI_PUB"};
                             |] in
  let ret = Backend.c_FindObjectsInit sessionh public_key_search_template in
  if compare ret Pkcs11.cKR_OK <> 0 then
    (* Error when initializing the research *)
    let s = Printf.sprintf "[User defined extensions]: X509 injection: could not initialize an object research with C_FindObjectsInit, got %s" (Pkcs11.match_cKR_value ret) in
    let _ = print_debug s 1 in
    failwith(s)
  else
    let count = ref 1n in
    let handles = ref [||] in

    while compare !count 0n <> 0 do
      (* Loop until we have found all the objects *)
      let (ret, handle_array, the_count) = Backend.c_FindObjects sessionh 1n in
      let _ = (count := the_count) in
      if compare ret Pkcs11.cKR_OK <> 0 then
        (* If we have an error, abort *)
        let s = Printf.sprintf "[User defined extensions]: X509 injection: could not process public keys research with C_FindObjects, got %s" (Pkcs11.match_cKR_value ret) in
        let _ = print_debug s 1 in
        failwith(s)
      else
        (* Add the handle to the set of handles we want to check *)
        handles := Array.concat [!handles; handle_array];
    done;
    let ret = Backend.c_FindObjectsFinal sessionh in
    if compare ret Pkcs11.cKR_OK <> 0 then
      let s = Printf.sprintf "[User defined extensions]: X509 injection: could not finalize public keys research with C_FindObjectsFinal, got %s" (Pkcs11.match_cKR_value ret) in
      let _ = print_debug s 1 in
      failwith(s)
    else
      (* We have our handles, process each object *)
      let the_id = ref None in
      Array.iter (
        fun handle ->
          (* Get the interesting attributes from the public key *)
          let template = [|
                       {Pkcs11.type_ = Pkcs11.cKA_MODULUS; Pkcs11.value = [||]};
                       {Pkcs11.type_ = Pkcs11.cKA_PUBLIC_EXPONENT; Pkcs11.value = [||]};
                       {Pkcs11.type_ = Pkcs11.cKA_ID; Pkcs11.value = [||]};
                       {Pkcs11.type_ = Pkcs11.cKA_LABEL; Pkcs11.value = [||]};
                          |] in
          let (ret, template_values) = Backend.c_GetAttributeValue sessionh handle template in
          let (ret, template_values) = Backend.c_GetAttributeValue sessionh handle template_values in
          if compare ret Pkcs11.cKR_OK <> 0 then
            (* Error when getting the attributes, go to the next handle *)
            ()
          else
            let s = Printf.sprintf ">>> %s %s" (base64_encode modulus_der) (base64_encode (Pkcs11.char_array_to_string template_values.(0).Pkcs11.value)) in
            let _ = print_debug s 1 in
            let found_modulus = normalize_big_int (Pkcs11.char_array_to_string template_values.(0).Pkcs11.value) in
            let search_modulus = normalize_big_int modulus_der in
            let found_exponent = normalize_big_int (Pkcs11.char_array_to_string template_values.(1).Pkcs11.value) in
            let search_exponent = normalize_big_int exponent_der in
            (* Compare the values we have got with the ones we had from the x509 certificate *)
            if (compare found_modulus search_modulus = 0) &&
               (compare found_exponent search_exponent = 0) then
              (* We are good only if the LABEL is an ANSSIPKI_PUB one *)
              if compare template_values.(3).Pkcs11.value (Pkcs11.string_to_char_array "ANSSIPKI_PUB") = 0 then
                the_id := Some template_values.(2).Pkcs11.value
              else
                (* Skip to the next handle *)
                ()
            else
              (* Skip to the next handle *)
              ()
      ) !handles;
      if compare !the_id None = 0 then
        (* Public key corresponfing to x509 not found, return an error *)
        let s = Printf.sprintf "[User defined extensions]: X509 injection: could not find the public key corresponding to the given certificate: are you sure it has been generated on the token?" in
        let _ = print_debug s 1 in
        failwith(s)
      else
        (get !the_id)


(* Function to fomat a signed X509 certificate given its DER encoding as well as its signature *)
let format_x509_data data signature_data mechanism =
  let oid_name = (
    if compare mechanism Pkcs11.cKM_SHA1_RSA_PKCS = 0 then
      ("sha1WithRSAEncryption")
    else if compare mechanism Pkcs11.cKM_SHA256_RSA_PKCS = 0 then
      ("sha256WithRSAEncryption")
    else if compare mechanism Pkcs11.cKM_SHA512_RSA_PKCS = 0 then
      ("sha512WithRSAEncryption")
    else
      let s = Printf.sprintf "[User defined extensions]: ANSSIPKI object handling: error when forging the x509 object, unsupported mechanism %s" (Pkcs11.match_cKM_value mechanism) in
      let _ = print_debug s 1 in
      failwith s;
  ) in
  (build_asn1_representation (x509_data_scheme_c (Pkcs11.char_array_to_string data) (Pkcs11.char_array_to_string signature_data) oid_name) "")

let current_signature_concerns_anssipki = ref false
let current_signature_mechanism = ref 0n

let anssipki_filter_usage fun_name arg =
  (* We block unsused functions (crypto other than sign) *)
  (* and restrict the creation templates                 *)
  match fun_name with
      (**** Restrict crypto usage ************************)
    (********************************************************************************)
      ("C_EncryptInit" |  "C_DecryptInit" | "C_SignRecoverInit" | "C_VerifyRecoverInit") ->
        let (sessionh, mech, objecth) = deserialize arg in
        let check = anssipki_check_label sessionh objecth in
        if check = true then
          let s = Printf.sprintf "[User defined extensions]: ANSSIPKI object handling: blocking %s operation" fun_name in
          let _ = print_debug s 1 in
          (* The label concerns ANSSI PKI, we refuse to perform the operation *)
          (serialize (true, (Pkcs11.cKR_FUNCTION_FAILED)))
        else
          (* The label is not concerned, passthrough *)
          (serialize (false, ()))
    (********************************************************************************)
    | "C_WrapKey" ->
        (* We refuse to use an ANSSI_PKI object to wrap other keys *)
        let (sessionh, _, wrappingh, _) = deserialize arg in
        (* If an invalid handle has been provided, we passthrough since it is a PKCS#12 export init *)
        if compare wrappingh Pkcs11.cK_INVALID_HANDLE = 0 then
          (* Passthrough *)
          (serialize (false, ()))
        else
          let check = anssipki_check_label sessionh wrappingh in
          if check = true then
            let s = Printf.sprintf "[User defined extensions]: ANSSIPKI object handling: blocking %s operation" fun_name in
            let _ = print_debug s 1 in
            (* The label concerns ANSSI PKI, we refuse to perform the operation *)
            (serialize (true, (Pkcs11.cKR_FUNCTION_FAILED, [||])))
          else
            (* The label is not concerned, passthrough *)
            (serialize (false, ()))
    (********************************************************************************)
    | "C_SignInit" ->
        let (sessionh, mechanism, objecth) = deserialize arg in
        let mech = mechanism.Pkcs11.mechanism in
        let check = anssipki_check_label sessionh objecth in
        if check = true then
          (* The label concerns ANSSI PKI, we keep this in memory *)
          let _ = (current_signature_concerns_anssipki := true; current_signature_mechanism := mech) in
          (* Passthrough *)
          (serialize (false, ()))
        else
          (* The signature does not concern an ANSSI PKI object *)
          let _ = (current_signature_concerns_anssipki := false; current_signature_mechanism := mech) in
          (* Passthrough *)
          (serialize (false, ()))
    (********************************************************************************)
    | "C_Sign" ->
         let (sessionh, data) = deserialize arg in
         if !current_signature_concerns_anssipki = true then
           (* If the call concerns an ANSSI PKI object, use the X509 validator *)
           let (check_validate, type_validate) = anssipki_validate_x509 data in
           if check_validate = true then
             (* The validator is OK, we call the real C_Sign and get the signature *)
             match type_validate with
               X509(subject_der_data, modulus_der_data, exponent_der_data) ->
                 (* Sign the TBS *)
                 let (ret, signature_data) = Backend.c_Sign sessionh data in
                 if compare ret Pkcs11.cKR_OK <> 0 then
                   (* If C_Sign has returned an error, we return the same error *)
                   (serialize (true, (ret, [||])))
                 else
                   (* We have a X509 object, we will sign it internally and inject it in the token *)
                   (* Before signing, find the ID of the public key that is associated to this certificate *)
                   let id = get_id_of_x509_from_public_key sessionh modulus_der_data exponent_der_data in
                   (* We have the signature, now create the object in the token *)
                   (* First, we format the X509 certificate with its signature *)
                   let x509_der_data = format_x509_data data signature_data !current_signature_mechanism in
                   let creation_template = Array.concat [ anssipki_x509_cert_creation_basic_template;
                                                            [|
                                   {Pkcs11.type_ = Pkcs11.cKA_VALUE; Pkcs11.value = Pkcs11.string_to_char_array x509_der_data};
                                   {Pkcs11.type_ = Pkcs11.cKA_SUBJECT; Pkcs11.value = Pkcs11.string_to_char_array subject_der_data};
                                   {Pkcs11.type_ = Pkcs11.cKA_ID; Pkcs11.value = id};
                                                             |] ] in
                   let (ret_create, _) = Backend.c_CreateObject sessionh creation_template in
                   (* Check if the creation went OK *)
                   if compare ret_create Pkcs11.cKR_OK = 0 then
                     (* If it is OK, return OK with the signature *)
                     (serialize (true, (Pkcs11.cKR_OK, signature_data)))
                   else
                     (* Return the creation error with an empty signature *)
                     (serialize (true, (ret_create, [||])))
             | _ ->
               (* If we have a CRL, we passthrough and return the backend return value *)
               (serialize (false, ()))
           else
             (* The validator returned an error, we don't allow the signature *)
             (* First we finalize the Sign session *)
             let _ = Pkcs11.c_SignFinal sessionh in
             (* Then, we return an error *)
             (serialize (true, (Pkcs11.cKR_DATA_INVALID, [| |])))
         else
           (* Passthrough *)
           (serialize (false, ()))
    (********************************************************************************)
    | "C_SignUpdate" ->
         let (sessionh, data) = deserialize arg in
         if !current_signature_concerns_anssipki = true then
           (* We do not allow multi-part signatures that concern ANSSI PKI objects *)
           (* First we finalize the Sign session *)
           let _ = Pkcs11.c_SignFinal sessionh in
           (* Then we return an error *)
           (serialize (true, (Pkcs11.cKR_FUNCTION_FAILED)))
         else
            (* Passthrough *)
            (serialize (false, ()))
      (**** Restrict modification usage **********************)
    (********************************************************************************)
    | ("C_CopyObject" | "C_SetAttributeValue")  ->
        let (sessionh, objecth, attributes) = deserialize arg in
        let check = anssipki_check_label sessionh objecth in
        if check = true then
          let s = Printf.sprintf "[User defined extensions]: ANSSIPKI object handling: blocking %s operation" fun_name in
          let _ = print_debug s 1 in
          (* The object is an ANSSI PKI one: return an error *)
          if compare fun_name "C_CopyObject" = 0 then
            (serialize (true, (Pkcs11.cKR_FUNCTION_FAILED, Pkcs11.cK_INVALID_HANDLE)))
          else
            (serialize (true, (Pkcs11.cKR_FUNCTION_FAILED)))
        else
          (* Passthrough *)
          (serialize (false, ()))
      (**** Restrict creation usage **************************)
      (* We check that all the created objects for ANSSIPKI have the proper flags *)
    (********************************************************************************)
    | ("C_UnwrapKey" | "C_CreateObject" | "C_DeriveKey" | "C_GenerateKey") ->
        let check_unwrap = (
          if compare fun_name "C_UnwrapKey" = 0 then
            (* We refuse to use an ANSSI_PKI object to unwrap something *)
            let (sessionh, _, unwrappingh, _, _) = deserialize arg in
            let check = anssipki_check_label sessionh unwrappingh in
            if check = true then
              (* The label concerns ANSSI PKI, we refuse to perform the operation *)
              (true)
            else
              (* The label is not concerned, passthrough *)
              (false)
         else
           (* This is not an Unwrap *)
           (false)) in
       let check_create = (
          if compare fun_name "C_CreateObject" = 0 then
            (* We refuse to allow a CreateObject for ANSSI_PKI objects *)
            let (_, attributes_array) = deserialize arg in
            if anssipki_check_label_in_attribute attributes_array = true then
              (* The label concerns ANSSI PKI, we refuse to perform the operation *)
              (true)
            else
              (* The label is not concerned, passthrough *)
              (false)
         else
           (* This is not an C_CreateObject *)
           (false)) in
        let check_derive = (
          if compare fun_name "C_DeriveKey" = 0 then
            (* We refuse to allow a DeriveKey for ANSSI_PKI objects, ot the creation of an *)
            (* ANSSI_PKI object through an *)
            let (sessionh, _, keyh, attributes_array) = deserialize arg in
            if (anssipki_check_label_in_attribute attributes_array = true) || (anssipki_check_label sessionh keyh = true) then
              (* The label concerns ANSSI PKI, we refuse to perform the operation *)
              (true)
            else
              (* The label is not concerned, passthrough *)
              (false)
         else
           (* This is not an Unwrap *)
           (false)) in
       let attributes_array = (match fun_name with
           "C_UnwrapKey" -> let (_, _, _, _, extracted_attributes_array) = deserialize arg in (extracted_attributes_array)
         | "C_CreateObject" -> let (_, extracted_attributes_array) = deserialize arg in (extracted_attributes_array)
         | "C_DeriveKey" -> let (_, _, _, extracted_attributes_array) = deserialize arg in (extracted_attributes_array)
         | "C_GenerateKey" -> let (_, _, extracted_attributes_array) = deserialize arg in (extracted_attributes_array)
         (* We should not end up here ... *)
         | _ -> ([||])) in
       (* Check if the concerned label is ANSSIPKI *)
       if anssipki_check_label_in_attribute attributes_array = true then
         (* Check if one of the forbidden attributes is set *)
         let check = check_anssipki_fobidden_attributes attributes_array in
         if (check_unwrap = true) || (check_create = true) || (check_derive = true) then
           let s = Printf.sprintf "[User defined extensions]: ANSSIPKI object handling: blocking %s operation" fun_name in
           let _ = print_debug s 1 in
           (serialize (true, (Pkcs11.cKR_FUNCTION_FAILED, Pkcs11.cK_INVALID_HANDLE)))
         else
           if check = true then
             let s = Printf.sprintf "[User defined extensions]: ANSSIPKI object handling: blocking %s operation because a forbidden attribute has been asked during the creation of the object" fun_name in
             let _ = print_debug s 1 in
             (* If one of the forbidden attributes is set, we return an error *)
             (serialize (true, (Pkcs11.cKR_TEMPLATE_INCONSISTENT, Pkcs11.cK_INVALID_HANDLE)))
           else
             (* Everything is OK, passthrough *)
             (serialize (false, ()))
       else
         (* Else we passthrough *)
         (serialize (false, ()))
    (********************************************************************************)
    | "C_GenerateKeyPair" ->
      let (_, _, pub_attributes_array, priv_attributes_array) = deserialize arg in
      (* Check if the concerned label is ANSSI_PKI *)
      let check_pub = (if anssipki_check_label_in_attribute pub_attributes_array = true then
        (check_anssipki_fobidden_attributes pub_attributes_array) else false) in
      let check_priv = (if anssipki_check_label_in_attribute priv_attributes_array = true then
        (check_anssipki_fobidden_attributes priv_attributes_array) else false) in
      if (check_pub || check_priv) = true then
          let s = Printf.sprintf "[User defined extensions]: ANSSIPKI object handling: blocking %s operation because a forbidden attribute has been asked during the creation of the object" fun_name in
          let _ = print_debug s 1 in
          (* If one of the forbidden attributes is set, we return an error *)
          (serialize (true, (Pkcs11.cKR_TEMPLATE_INCONSISTENT, Pkcs11.cK_INVALID_HANDLE, Pkcs11.cK_INVALID_HANDLE)))
      else
       (* Else we passthrough *)
       (serialize (false, ()))
    (* Default if we are in a non concerned function is to passthrough *)
    | _ -> (serialize (false, ()))



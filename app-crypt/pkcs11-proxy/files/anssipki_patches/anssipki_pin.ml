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

let anssipki_pin fun_name arg =
   match fun_name with
    "C_Login" ->
     let (cksessionhandlet_, ckusertypet_, pin) = deserialize arg in
     (* We have a login request, get the real pin from the user *)
     let (ret_status, pwd, error_message) = fork_exec_command anssipki_external_get_pin_handler "" anssipki_external_get_pin_handler_args anssipki_external_get_pin_handler_env in     
     if ret_status = true then
       (* We have the real pin, call the real c_Login *)
       let ret_clogin = Backend.c_Login cksessionhandlet_ ckusertypet_ (Pkcs11.string_to_char_array pwd) in
       (serialize (true, ret_clogin))
     else
       (* Error during the external command: log and return an error *)
       let s = Printf.sprintf "[User defined extensions]: error during C_Login PIN catching, command %s returned %s on stderr" anssipki_external_get_pin_handler error_message in
       let _ = print_debug s 1 in
       (serialize (true, (Pkcs11.cKR_GENERAL_ERROR)))
   | "C_InitPIN" ->
      let (cksessionhandlet_, pin) = deserialize arg in
     (* We have a set PIN request, get the real pin from the user *)
     let (ret_status, pwd, error_message) = fork_exec_command anssipki_external_get_pin_handler "" anssipki_external_get_pin_handler_args anssipki_external_get_pin_handler_env in     
     if ret_status = true then
       (* We have the real pin, call the real c_InitPIN *)
       let ret_cinitpin = Backend.c_Login cksessionhandlet_ cksessionhandlet_ (Pkcs11.string_to_char_array pwd) in
       (serialize (true, (ret_cinitpin)))
     else
       (* Error during the external command: log and return an error *)
       let s = Printf.sprintf "[User defined extensions]: error during C_InitPIN catching, command %s returned %s on stderr" anssipki_external_get_pin_handler error_message in
       let _ = print_debug s 1 in
       (serialize (true, (Pkcs11.cKR_GENERAL_ERROR)))
   | "C_SetPIN" ->
     let (cksessionhandlet_, old_pin, new_pin) = deserialize arg in
     (* We have a change PIN request, get the real old pin from the user *)
     let (ret_status, old_pwd, error_message) = fork_exec_command anssipki_external_get_pin_handler "" anssipki_external_get_pin_handler_args anssipki_external_get_pin_handler_env in     
     if ret_status = true then
       (* Get the new pin *)
       let (ret_status, new_pwd, error_message) = fork_exec_command anssipki_external_get_pin_handler "" anssipki_external_get_pin_handler_args anssipki_external_get_pin_handler_env in
       if ret_status = true then
         (* We have the real pin, call the real c_SetPIN *)
         let ret_csetpin = Backend.c_SetPIN cksessionhandlet_ (Pkcs11.string_to_char_array old_pwd) (Pkcs11.string_to_char_array new_pwd) in
         (serialize (true, (ret_csetpin)))
       else
         let s = Printf.sprintf "[User defined extensions]: error during C_SetPIN new PIN catching, command %s returned %s on stderr" anssipki_external_get_pin_handler error_message in
         let _ = print_debug s 1 in
         (serialize (true, (Pkcs11.cKR_GENERAL_ERROR)))
     else
       (* Error during the external command: log and return an error *)
       let s = Printf.sprintf "[User defined extensions]: error during C_SetPIN old PIN catching, command %s returned %s on stderr" anssipki_external_get_pin_handler error_message in
       let _ = print_debug s 1 in
       (serialize (true, (Pkcs11.cKR_GENERAL_ERROR)))
   (* Default if we are in a non concerned function is to passthrough *)
   | _ -> (serialize (false, ()))


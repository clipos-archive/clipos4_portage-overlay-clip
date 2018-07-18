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

let anssipki_external_x509_validator = ""
let anssipki_external_x509_validator_args = [||]
let anssipki_external_x509_validator_env = None

let anssipki_external_pwd_handler = "/bin/pinentry-client"
let anssipki_external_pwd_handler_args = [| "/var/run/ssm_display/socket" ; "c" |]
let anssipki_external_pwd_handler_env = None

let anssipki_external_get_pin_handler = "/bin/pinentry-client"
let anssipki_external_get_pin_handler_args = [| "/var/run/ssm_display/socket" ; "b" |]
let anssipki_external_get_pin_handler_env = None

(* Regexps of ANSSIPKI labels *)
let anssipki_cert_label = "ANSSIPKI_CERT"
let anssipki_labels = [| "ANSSIPKI" |]

let anssipki_is_label_concerned label =
  let check = Array.fold_left (
    fun curr_check a ->
      (curr_check || (check_regexp a label))
  ) false anssipki_labels in
  (check)

(* Check if a given object has an ANSSIPKI label *)
let anssipki_check_label sessionh objecth =
  let (ret, returned_attributes) = Backend.c_GetAttributeValue sessionh objecth [| {Pkcs11.type_ = Pkcs11.cKA_LABEL; Pkcs11.value = [||]} |] in
  if compare ret Pkcs11.cKR_OK <> 0 then
    (* Cannot get the label, there is a problem!  *)
    let s = "[User defined extensions] C_GettAttributeValue CRITICAL ERROR when getting LABEL (ANSSI_PKI patch)\n" in netplex_log_critical s; failwith s;
  else
    let (ret, returned_attributes) = Backend.c_GetAttributeValue sessionh objecth returned_attributes in
      if compare ret Pkcs11.cKR_OK <> 0 then
        (* Cannot get the label, there is a problem!  *)
        let s = "[User defined extensions] C_GettAttributeValue CRITICAL ERROR when getting LABEL (ANSSI_PKI patch)\n" in netplex_log_critical s; failwith s;
      else
        (* We have the LABEL, now compare it to reference regexp labels *)
        (anssipki_is_label_concerned (Pkcs11.char_array_to_string returned_attributes.(0).Pkcs11.value))

(* Check if there is an ANSSIPKI label in an array attributes *)
let anssipki_check_label_in_attribute attributes_array = 
  let check = Array.fold_left (
    fun curr_check attrib ->
      (* Do we have a label? *)
      if compare attrib.Pkcs11.type_ Pkcs11.cKA_LABEL = 0 then
        if anssipki_is_label_concerned (Pkcs11.char_array_to_string attrib.Pkcs11.value) = true then
          (curr_check || true)
        else
          (curr_check || false)
      else
        (curr_check || false)
  ) false attributes_array in
  (check)

let fork_exec_command_ cmd data argvs env =
  (* Open three pipes: stdin, stdout, stderr *)
  let (child_stdin, parent_out) = (try Unix.pipe()
    with e -> raise e) in
  let (parent_in1, child_stdout) = (try Unix.pipe()
    with e -> raise e) in
  let (parent_in2, child_stderr) = (try Unix.pipe()
    with e -> raise e) in
  let pid = Unix.fork () in
    match pid with
    | 0 ->
        (* Connect child pipes to stdin/stdout/stderr *)
        (try Unix.dup2 child_stdin Unix.stdin
          with e -> raise e);
        (try Unix.dup2 child_stdout Unix.stdout
          with e -> raise e);
        (try Unix.dup2 child_stderr Unix.stderr
          with e -> raise e);
        (* Close unnecessary file descriptors *)
        Unix.close child_stdin;
        Unix.close child_stdout;
        Unix.close child_stderr;
        Unix.close parent_out;
        Unix.close parent_in1;
        Unix.close parent_in2;
        (* Get the environment *)
        (match env with
          |None ->
            (* No environment given: inherit from parent env *)
            (try
               Unix.execvp cmd (Array.concat [[| cmd |]; argvs])
             with
               e -> raise e)
          |Some call_env ->
            (* Apply new environment during execve *)
            (try
               Unix.execve cmd (Array.concat [[| cmd |]; argvs]) call_env
             with
               e -> raise e));
    | -1 -> (false, "", "")
    | _ ->
      (* Close unnecessary file descriptors *)
      Unix.close child_stdin;
      Unix.close child_stdout;
      Unix.close child_stderr;
      (* Send the input data to child stdin through the pipe *)
      let written = (try Unix.single_write parent_out data 0 (String.length data)
        with _ -> 0) in
      if written <> (String.length data) then
         begin
         (false, "", "")
         end
      else
        begin
        (* Close write channel to tell it is over *)
        Unix.close parent_out;
        (* Wait for process termination and get its exit status *)
        let retcode =
          (match Unix.waitpid [] pid
            with
             |(pid, Unix.WEXITED 0) -> true
             |_ -> false) in
        (* Now read what the child has to tell us *)
        let max_read_size = 2048 in
        let bytes_read = ref 0 in
        let buffer_tmp = ref (String.create max_read_size) in
        (* STDOUT *)
        bytes_read := max_read_size;
        let buffer_stdout = ref "" in
        while !bytes_read <> 0 do
          bytes_read := (try Unix.read parent_in1 !buffer_tmp 0 max_read_size with e -> raise e);
          buffer_stdout := !buffer_stdout ^ (String.sub !buffer_tmp 0 !bytes_read);
        done;
        (* STDERR *)
        bytes_read := max_read_size;
        let buffer_stderr = ref "" in
        while !bytes_read <> 0 do
          bytes_read := (try Unix.read parent_in2 !buffer_tmp 0 max_read_size with e -> raise e);
          buffer_stderr := !buffer_stderr ^ (String.sub !buffer_tmp 0 !bytes_read);
        done;
        (* Close file descriptors *)
        Unix.close parent_in1;
        Unix.close parent_in2;
        (retcode, !buffer_stdout, !buffer_stderr)
        end

let fork_exec_command cmd data argvs env =
  let ret = (try fork_exec_command_ cmd data argvs env
             with _ -> (false, "", "")) in
  (ret)

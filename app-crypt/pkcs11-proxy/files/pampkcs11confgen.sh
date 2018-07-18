#!/bin/sh
# Copyright 2018 ANSSI
# Distributed under the terms of the GNU General Public License v2

PAM_PKCS11_CONF="/var/run/pam_pkcs11.conf"

cat > "${PAM_PKCS11_CONF}" <<EOF
pam_pkcs11 {
  nullok = false;
  debug = false; 
  use_first_pass = false;
  try_first_pass = false;
  use_authtok = false;
  use_pkcs11_module = p11proxy;

  pkcs11_module p11proxy {
    module = /usr/lib/p11proxy.so;
    slot_num = 0;
    description = "P11 proxy client module";
    ca_dir = /etc/admin/pkcs11/cacerts;
    crl_dir = /etc/admin/pkcs11/crls;
    support_threads = false;
    cert_policy = ca,signature;
    label = "${1}";
  }

  use_mappers = subject;
  mapper_search_path = /usr/lib/pam_pkcs11;

  mapper subject {
        debug = false;
        module = internal;
        ignorecase = false;
        mapfile = file:///home/etc.users/subject_mapping;
  }
}
EOF


chmod 644 "${PAM_PKCS11_CONF}"



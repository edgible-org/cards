#!/bin/sh
# keeper-sh is on none, so anyone can reach it. An address outside KEEPER_SH_SIGNUP_DOMAINS must not
# be able to make an account.
set -eu
B="https://$HOSTNAME_KEEPER_SH"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/auth/sign-up/email" -H 'Content-Type: application/json' \
       -d '{"email":"stranger@not-allowed.example","password":"Str4nger-pass-123!","name":"S"}')
case "$code" in 4*) ;; *) echo "a stranger's sign-up answered $code"; exit 1 ;; esac

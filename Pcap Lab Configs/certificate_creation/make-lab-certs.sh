#!/usr/bin/env bash
# make-lab-certs.sh - PCAP Lab certificates for EAP-PEAP
#
# Creates a lab Root CA and a RADIUS server certificate signed by it.
# For LAB USE ONLY. Do not use these certificates in production.
#
# Output (in the current directory):
#   ca.pem       Lab Root CA certificate
#   ca.key       Lab Root CA private key   (keep private, do not commit)
#   server.pem   RADIUS server certificate (signed by the lab CA)
#   server.key   RADIUS server private key (keep private, do not commit)

set -euo pipefail

CA_SUBJ="/C=US/O=MyLab/CN=MyLab Root CA"
SERVER_CN="radius.example.local"
SERVER_SUBJ="/C=US/O=MyLab/CN=${SERVER_CN}"

# 1. Lab Root CA (10 years)
openssl req -x509 -newkey rsa:2048 -nodes -sha256 -days 3650 \
  -keyout ca.key -out ca.pem \
  -subj "${CA_SUBJ}" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,keyCertSign,cRLSign"

# 2. Server key and certificate signing request
openssl req -newkey rsa:2048 -nodes -sha256 \
  -keyout server.key -out server.csr \
  -subj "${SERVER_SUBJ}"

# 3. Server certificate extensions (TLS server, with SAN)
cat > server.ext <<EOF
basicConstraints=CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=DNS:${SERVER_CN}
EOF

# 4. Sign the server certificate with the lab CA (825 days)
openssl x509 -req -sha256 -days 825 \
  -in server.csr -CA ca.pem -CAkey ca.key -CAcreateserial \
  -out server.pem -extfile server.ext

# 5. Clean up and lock down the private keys
rm -f server.csr server.ext ca.srl
chmod 600 ca.key server.key

# 6. Verify the chain
openssl verify -CAfile ca.pem server.pem

echo
echo "Done. Copy to hostapd with:"
echo "  sudo mkdir -p /etc/hostapd/certs"
echo "  sudo cp ca.pem server.pem server.key /etc/hostapd/certs/"
echo "  sudo chmod 600 /etc/hostapd/certs/server.key"

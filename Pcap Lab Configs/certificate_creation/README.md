# Lab Certificates (EAP-PEAP)

The EAP-PEAP lab needs a server certificate for the PEAP outer tunnel (TLS).
`hostapd_8021x.conf` expects these files:

| hostapd setting | File |
|---|---|
| `ca_cert` | `/etc/hostapd/certs/ca.pem` |
| `server_cert` | `/etc/hostapd/certs/server.pem` |
| `private_key` | `/etc/hostapd/certs/server.key` |

`private_key_passwd=` is left empty because the script creates an unencrypted key.

> **Lab use only.** Generate your own certificates. Never commit private keys (`*.key`) to the repo.

## Option 1: Run the script

The script runs all the OpenSSL commands from Option 2 for you, checks the result, and prints the install commands.

**What you need**

- A Linux machine with OpenSSL 1.1.1 or newer. Check with:

  ```bash
  openssl version
  ```

  If it's missing: `sudo apt install openssl`

**Step 1: Go to the certs folder**

From the root of the repo:

```bash
cd "Pcap Lab Configs/certs"
```

**Step 2: Make the script executable**

You only need to do this once.

```bash
chmod +x make-lab-certs.sh
```

**Step 3: Run it**

```bash
./make-lab-certs.sh
```

There's no need for `sudo` here. The script only writes files to the current folder.

**Step 4: Check the output**

The script ends by verifying the certificate chain. You should see:

```
server.pem: OK

Done. Copy to hostapd with:
  sudo mkdir -p /etc/hostapd/certs
  sudo cp ca.pem server.pem server.key /etc/hostapd/certs/
  sudo chmod 600 /etc/hostapd/certs/server.key
```

You'll now have four new files in the folder:

| File | What it is |
|---|---|
| `ca.pem` | Lab Root CA certificate |
| `ca.key` | Lab Root CA private key (keep private) |
| `server.pem` | RADIUS server certificate, signed by the lab CA |
| `server.key` | RADIUS server private key (keep private) |

The `.gitignore` in this folder stops these files from being committed.

**Step 5: Install them**

Run the commands the script printed, then follow [Install for hostapd](#install-for-hostapd).

**Running it again**

Running the script again overwrites all four files with a brand-new CA and server certificate. Re-copy them to `/etc/hostapd/certs/` and restart hostapd. If a client's `ca_cert` points at the old `ca.pem`, update it too.

**Troubleshooting**

- `Permission denied`: you skipped Step 2. Run `chmod +x make-lab-certs.sh`, or run it with `bash make-lab-certs.sh`.
- `unknown option -addext` or similar: your OpenSSL is older than 1.1.1. Update OpenSSL.
- `bad interpreter: /usr/bin/env^M`: the file picked up Windows line endings, which can happen when cloning on Windows. Fix with `sed -i 's/\r$//' make-lab-certs.sh`.

## Option 2: Run the commands yourself

**1. Create the lab Root CA**

```bash
openssl req -x509 -newkey rsa:2048 -nodes -sha256 -days 3650 \
  -keyout ca.key -out ca.pem \
  -subj "/C=US/O=MyLab/CN=MyLab Root CA" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,keyCertSign,cRLSign"
```

**2. Create the server key and signing request**

```bash
openssl req -newkey rsa:2048 -nodes -sha256 \
  -keyout server.key -out server.csr \
  -subj "/C=US/O=MyLab/CN=radius.example.local"
```

**3. Sign the server certificate with the lab CA**

```bash
cat > server.ext <<EOF
basicConstraints=CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=DNS:radius.example.local
EOF

openssl x509 -req -sha256 -days 825 \
  -in server.csr -CA ca.pem -CAkey ca.key -CAcreateserial \
  -out server.pem -extfile server.ext
```

**4. Verify**

```bash
openssl verify -CAfile ca.pem server.pem
# server.pem: OK
```

## Install for hostapd

```bash
sudo mkdir -p /etc/hostapd/certs
sudo cp ca.pem server.pem server.key /etc/hostapd/certs/
sudo chmod 600 /etc/hostapd/certs/server.key
```

Also copy the sample user file:

```bash
sudo cp ../hostapd/hostapd.eap_user /etc/hostapd/hostapd.eap_user
```

## How this maps to the lab

- **Validate server cert (Phase 1 fails):** `wpa_8021x_eap_peap_validate_server_cert.conf` points `ca_cert` at a public root CA, not this lab CA. The client cannot validate `server.pem`, sends a TLS **Unknown CA** alert, and the outer tunnel is never built.
- **Do NOT validate server cert (Phase 1 passes, Phase 2 fails):** `wpa_8021x_eap_peap_no_validate_server_cert.conf` has `ca_cert` commented out, so the client accepts any certificate. Phase 2 then fails because the user is commented out in `hostapd.eap_user`.
- **Optional, successful validation:** point the client's `ca_cert` at this lab's `ca.pem` and uncomment the Phase 2 user in `hostapd.eap_user`.

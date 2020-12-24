openssl ecparam -genkey -name prime256v1 -out client.key
openssl req -new -key client.key -out client.csr -subj "/C=GB/ST=PR/L=PR/O=Global Security/OU=DEV Department/CN=12345"
openssl x509 -req -in client.csr -CAkey keys/inter_signer/hoyos_int.key -CA keys/inter_signer/hoyos_int_chain.crt -CAcreateserial -extfile keys/local-ca.cnf -extensions device_key -days 1000 -out client.crt


#!/bin/bash

# create a client key
sudo openssl genrsa -out /etc/ssl/private/client-key.pem 4096

# certificate signing request
sudo openssl req -subj '/CN=client' -new -key /etc/ssl/private/client-key.pem -out /etc/ssl/certs/client.csr

# make the key suitable for client authentication
sudo /bin/bash -c 'echo extendedKeyUsage = clientAuth > /etc/ssl/certs/extfile-client.cnf'

# generate the signed certificate
sudo openssl x509 -req -days 365 -sha256 -in /etc/ssl/certs/client.csr -CA /etc/ssl/certs/ca-cert.pem -CAkey /etc/ssl/private/ca-key.pem \
  -CAcreateserial -passin pass:challenge -out /etc/ssl/certs/client-cert.pem -extfile /etc/ssl/certs/extfile-client.cnf

#------------------------------------------------------------------------------------------------

# remove the two certificate signing requests and extensions config files
sudo rm -v /etc/ssl/certs/client.csr /etc/ssl/certs/extfile-client.cnf 
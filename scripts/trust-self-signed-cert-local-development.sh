#!/bin/bash

echo $SELF_SIGNED_CERT | base64 -d > /tmp/self_signed_developer_cert_authority.crt

if [[ $OSTYPE =~ "linux" ]]; then
  echo "LINUX: copying self-signed certificate and updating"
  sudo cp /tmp/self_signed_developer_cert_authority.crt /usr/local/share/ca-certificates/tmp/self_signed_developer_cert_authority.crt
  sudo update-ca-certificates
elif [[ $OSTYPE =~ "darwin" ]]; then
  echo "MACOS: auto trust self-signed certificate using security binary"
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /tmp/self_signed_developer_cert_authority.crt
else
  echo "OPERATING SYSTEM NOT DETECTED; Doesn't seem to either be Linux nor Mac OS which are the only supported environments at this time"
  exit 1
fi
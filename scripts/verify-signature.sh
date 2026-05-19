#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <IMAGE>"
  exit 1
fi

IMAGE=$1

echo "Verifying image: $IMAGE"

# Step 1: Verify the Cosign signature
cosign verify --certificate-identity-regexp=https://github.com/srujantata/.* --certificate-oidc-issuer=https://token.actions.githubusercontent.com $IMAGE > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "verified"
else
  echo "not-verified"
fi

# Step 3: Download the SBOM
cosign download sbom $IMAGE

echo "Verification and SBOM retrieval completed."
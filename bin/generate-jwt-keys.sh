#!/bin/bash

set -e

echo "Generating JWT RSA key pair..."

# Create jwt directory if it doesn't exist
mkdir -p var/jwt

# Generate private key
openssl genpkey -algorithm RSA -out var/jwt/private.pem -pkeyopt rsa_keygen_bits:4096

# Generate public key from private key
openssl rsa -pubout -in var/jwt/private.pem -out var/jwt/public.pem

# Set proper permissions
chmod 600 var/jwt/private.pem
chmod 644 var/jwt/public.pem

echo "✓ JWT keys generated successfully!"
echo "  Private key: var/jwt/private.pem"
echo "  Public key: var/jwt/public.pem"
echo ""
echo "Note: Make sure to set JWT_PASSPHRASE in your .env.local file if you want to use a passphrase."
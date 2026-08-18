#!/usr/bin/env bash
# scan_secrets.sh - Scan files for potential secrets/credentials
# Usage: ./scan_secrets.sh file1 file2 file3 ...
# Exit code 0 = clean, 1 = secrets detected
#
# Handles encrypted .env files: recognizes encryption tool formats
# (sops, age, gpg, dotenv-vault, etc.) and plaintext .env distinction.

set -euo pipefail

# --- Encrypted file extensions: skip these, they are safe ---
ENCRYPTED_EXTENSIONS=(
  '\.enc$' '\.encrypted$' '\.age$' '\.gpg$' '\.pgp$'
  '\.sops\.json$' '\.sops\.yaml$' '\.sops\.env$'
  '\.vault$' '\.crypt$' '\.cipher$'
)

# --- Sensitive filename patterns (plaintext secrets) ---
SENSITIVE_FILE_PATTERNS=(
  '\.env$' '\.env\.local$' '\.env\.production$' '\.env\.staging$'
  '\.env\.dev$' '\.env\.test$'
  '\.env\.keys$'                  # dotenvx: contains DOTENV_PRIVATE_KEY, must block
  'id_rsa' 'id_ed25519' 'id_ecdsa'
  '\.pem$' '\.key$' '\.p12$' '\.pfx$'
  'credentials\.json$' 'service-account\.json$'
  'secrets\.json$' 'secrets\.yaml$' 'secrets\.yml$'
  '\.htpasswd$' '\.netrc$'
  'token\.json$' 'oauth.*\.json$'
)

# --- Content patterns indicating plaintext secrets ---
SECRET_CONTENT_PATTERNS=(
  'AWS_SECRET_ACCESS_KEY'
  'AWS_ACCESS_KEY_ID'
  'PRIVATE_KEY'
  'SECRET_KEY'
  'API_KEY\s*='
  'PASSWORD\s*='
  'TOKEN\s*='
  'BEGIN RSA PRIVATE KEY'
  'BEGIN EC PRIVATE KEY'
  'BEGIN OPENSSH PRIVATE KEY'
  'BEGIN PGP PRIVATE KEY'
  'DOTENV_PRIVATE_KEY'           # dotenvx: private key must never be committed
)

# --- Content patterns indicating encrypted/encoded files (safe to commit) ---
ENCRYPTED_CONTENT_MARKERS=(
  'ENC\['                          # sops / dotenv-vault encrypted values
  'sops_'                          # sops metadata
  'age-encryption\.org'            # age encryption header
  '-----BEGIN AGE ENCRYPTED FILE-----'
  '-----BEGIN PGP MESSAGE-----'    # GPG encrypted
  '-----BEGIN ENCRYPTED FILE-----'
  'vault:v[0-9]+:'                 # Vault transit encrypted
  'ENC[A-Za-z0-9+/=]+'            # generic base64 encrypted blocks (>20 chars)
  'DOTENV_PUBLIC_KEY'              # dotenvx: public key present
  'encrypted:[A-Za-z0-9+/=]+'     # dotenvx: encrypted value prefix
  'DOTENV_PUBLIC_KEY\]\-/'         # dotenvx: header banner marker
)

# --- Plaintext .env indicators ---
PLAINTEXT_ENV_MARKERS=(
  '^[A-Z_]+=[^$]'                  # KEY=value (non-empty, non-variable-ref)
  '^[a-z_]+=[^$]'
)

is_encrypted_extension() {
  local file="$1"
  for pattern in "${ENCRYPTED_EXTENSIONS[@]}"; do
    if echo "$file" | grep -qE "$pattern"; then
      return 0
    fi
  done
  return 1
}

is_encrypted_content() {
  local file="$1"
  for marker in "${ENCRYPTED_CONTENT_MARKERS[@]}"; do
    if grep -qE "$marker" "$file" 2>/dev/null; then
      return 0
    fi
  done
  return 1
}

is_plaintext_env() {
  local file="$1"
  local match_count=0
  local total_lines
  total_lines=$(wc -l < "$file" 2>/dev/null || echo 0)

  if [ "$total_lines" -eq 0 ]; then
    return 1
  fi

  for marker in "${PLAINTEXT_ENV_MARKERS[@]}"; do
    local count
    count=$(grep -cE "$marker" "$file" 2>/dev/null) || count=0
    match_count=$((match_count + count))
  done

  # If >30% of non-empty lines look like KEY=value, it's plaintext
  local non_empty
  non_empty=$(grep -c '.' "$file" 2>/dev/null || echo 1)
  local threshold=$((non_empty * 30 / 100))

  [ "$match_count" -gt "$threshold" ] && [ "$match_count" -ge 3 ]
}

if [ $# -eq 0 ]; then
  echo "NO_FILES"
  exit 0
fi

FOUND_SECRETS=0
FLAGGED_FILES=()

for file in "$@"; do
  if [ ! -f "$file" ]; then
    continue
  fi

  # Step 1: Skip files with encrypted extensions
  if is_encrypted_extension "$file"; then
    echo "ENCRYPTED_SKIP: $file (encrypted extension, safe)"
    continue
  fi

  # Step 2: For sensitive filename matches, check if content is encrypted
  filename_matched=0
  for pattern in "${SENSITIVE_FILE_PATTERNS[@]}"; do
    if echo "$file" | grep -qiE "$pattern"; then
      filename_matched=1
      break
    fi
  done

  if [ $filename_matched -eq 1 ]; then
    # First: check for explicit secret content (always block these regardless of encryption)
    for pattern in "${SECRET_CONTENT_PATTERNS[@]}"; do
      if grep -qiE "$pattern" "$file" 2>/dev/null; then
        echo "SENSITIVE_FILE: $file (matched filename: $pattern, contains secret content)"
        FLAGGED_FILES+=("$file")
        FOUND_SECRETS=1
        continue 2
      fi
    done

    # Check if the file content is actually encrypted
    if is_encrypted_content "$file"; then
      echo "ENCRYPTED_SKIP: $file (filename matches but content is encrypted, safe)"
      continue
    fi

    # For .env files, distinguish plaintext vs encrypted/non-secret
    if echo "$file" | grep -qiE '\.env'; then
      if ! is_plaintext_env "$file"; then
        echo "ENCRYPTED_SKIP: $file (no plaintext KEY=value patterns, likely encrypted/safe)"
        continue
      fi
    fi

    echo "SENSITIVE_FILE: $file (matched: $pattern, plaintext secrets detected)"
    FLAGGED_FILES+=("$file")
    FOUND_SECRETS=1
    continue
  fi

  # Step 3: Content-based detection for non-sensitive filenames
  if is_encrypted_content "$file"; then
    echo "ENCRYPTED_SKIP: $file (content appears encrypted, safe)"
    continue
  fi

  for pattern in "${SECRET_CONTENT_PATTERNS[@]}"; do
    if grep -qiE "$pattern" "$file" 2>/dev/null; then
      echo "SECRET_CONTENT: $file (matched: $pattern)"
      if [[ ! " ${FLAGGED_FILES[*]:-} " =~ " $file " ]]; then
        FLAGGED_FILES+=("$file")
      fi
      FOUND_SECRETS=1
      break
    fi
  done
done

if [ $FOUND_SECRETS -eq 0 ]; then
  echo "CLEAN: No secrets detected in ${#} file(s)"
  exit 0
else
  echo "ALERT: ${#FLAGGED_FILES[@]} file(s) contain potential secrets"
  exit 1
fi

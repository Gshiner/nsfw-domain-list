#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_FILE="$ROOT_DIR/porn-domains.txt"
CLASH_OUT="$ROOT_DIR/dist/clash/nsfw-reject.yaml"
SHADOWROCKET_OUT="$ROOT_DIR/dist/shadowrocket/nsfw-reject.list"
SHADOWROCKET_DOMAIN_SET_OUT="$ROOT_DIR/dist/shadowrocket/nsfw-reject-domain-set.list"
TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "missing source file: $SOURCE_FILE" >&2
  exit 1
fi

mkdir -p "$(dirname "$CLASH_OUT")" "$(dirname "$SHADOWROCKET_OUT")"

awk '
  /^[[:space:]]*$/ { next }
  /^[[:space:]]*#/ { next }
  {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
    print tolower($0)
  }
' "$SOURCE_FILE" | LC_ALL=C sort -u > "$TMP_DIR/domains.txt"

{
  echo "# Generated from porn-domains.txt. Do not edit by hand."
  echo "# For ClashX Pro / Clash Premium rule-provider, behavior: classical."
  echo "payload:"
  awk '{ print "  - DOMAIN-SUFFIX," $0 }' "$TMP_DIR/domains.txt"
} > "$CLASH_OUT"

{
  echo "# Generated from porn-domains.txt. Do not edit by hand."
  echo "# Use with Shadowrocket: RULE-SET,<this raw URL>,REJECT"
  awk '{ print "DOMAIN-SUFFIX," $0 }' "$TMP_DIR/domains.txt"
} > "$SHADOWROCKET_OUT"

cp "$TMP_DIR/domains.txt" "$SHADOWROCKET_DOMAIN_SET_OUT"

echo "generated:"
wc -l "$CLASH_OUT" "$SHADOWROCKET_OUT" "$SHADOWROCKET_DOMAIN_SET_OUT"

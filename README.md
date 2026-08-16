# NSFW Reject Rules

This repository keeps one source domain list and publishes generated rule files for ClashX Pro and Shadowrocket.

## Files

```text
porn-domains.txt                    # single source of truth
dist/clash/nsfw-reject.yaml         # ClashX Pro rule-provider file
dist/shadowrocket/nsfw-reject.list  # Shadowrocket RULE-SET file
dist/shadowrocket/nsfw-reject-domain-set.list # Shadowrocket DOMAIN-SET file
scripts/build-rules.sh              # regenerate dist files from the source list
metadata/porn-collector-report.json # source collection summary
```

## Update Rules

Edit `porn-domains.txt`, then run:

```bash
./scripts/build-rules.sh
```

Commit and push the updated source list plus generated files.

## ClashX Pro

Use the GitHub raw URL for `dist/clash/nsfw-reject.yaml`:

```yaml
rule-providers:
  nsfw-reject:
    type: http
    behavior: classical
    url: https://raw.githubusercontent.com/Gshiner/nsfw-domain-list/main/dist/clash/nsfw-reject.yaml
    path: ./ruleset/nsfw-reject.yaml
    interval: 86400

rules:
  - RULE-SET,nsfw-reject,REJECT
```

Put this rule before proxy/global rules so it wins first.

## Shadowrocket

Prefer `DOMAIN-SET` because it is smaller and lighter for iOS:

```text
DOMAIN-SET,https://raw.githubusercontent.com/Gshiner/nsfw-domain-list/main/dist/shadowrocket/nsfw-reject-domain-set.list,REJECT
```

If a config only supports `RULE-SET`, use:

```text
RULE-SET,https://raw.githubusercontent.com/Gshiner/nsfw-domain-list/main/dist/shadowrocket/nsfw-reject.list,REJECT
```

Put it before general proxy rules.

## GitHub Actions

When `porn-domains.txt` changes on `main`, the workflow in `.github/workflows/build-rules.yml` runs `scripts/build-rules.sh` and commits updated `dist/` files if needed.

## Notes

- `REJECT` blocks matching domains instead of routing them through VPN.
- `dist/` files are generated. Do not edit them by hand.
- Keep the repository public if clients need to fetch raw URLs without login or tokens.

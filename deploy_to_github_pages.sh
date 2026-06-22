#!/usr/bin/env bash
set -euo pipefail
OWNER="cnbuyspreadsheet"
REPO="Oopbuy-Spreadsheet"
BASE="https://cnbuyspreadsheet.github.io/Oopbuy-Spreadsheet"
SITE_DIR="/home/zrg/res/oopbuy-spreadsheet"
cd "$SITE_DIR"
TOKEN="${GITHUB_TOKEN:-}"
if [ -z "$TOKEN" ]; then printf 'GitHub token: '; read -r -s TOKEN; printf '
'; fi
if [ -z "$TOKEN" ]; then echo "Token is required." >&2; exit 1; fi
AUTH_HEADER="Authorization: Bearer $TOKEN"
ACCEPT_HEADER="Accept: application/vnd.github+json"
askpass_file=""
cleanup(){ [ -n "$askpass_file" ] && [ -f "$askpass_file" ] && rm -f "$askpass_file"; }
trap cleanup EXIT
askpass_file=$(mktemp)
cat > "$askpass_file" <<EOF
#!/usr/bin/env bash
case "\$1" in
  *Username*) printf '%s
' '$OWNER' ;;
  *Password*) printf '%s
' '$TOKEN' ;;
  *) printf '%s
' '$TOKEN' ;;
esac
EOF
chmod 700 "$askpass_file"
export GIT_ASKPASS="$askpass_file"
export GIT_TERMINAL_PROMPT=0
python3 ~/.hermes/skills/static-site-patterns/scripts/static_site_predeploy_check.py "$SITE_DIR" "$BASE"
LOGIN=$(curl -fsS -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" https://api.github.com/user | python3 -c 'import sys,json; print(json.load(sys.stdin).get("login",""))')
[ "$LOGIN" = "$OWNER" ] || { echo "Token user '$LOGIN' does not match '$OWNER'" >&2; exit 1; }
STATUS=$(curl -sS -o /tmp/oopbuy_repo_check.json -w '%{http_code}' -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" "https://api.github.com/repos/$OWNER/$REPO")
if [ "$STATUS" = "404" ]; then curl -fsS -X POST -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" https://api.github.com/user/repos -d '{"name":"'$REPO'","private":false,"description":"Curated OopBuy finds, QC notes, shipping guides, and category research for smarter agent shopping.","has_issues":true,"has_wiki":false}' >/tmp/oopbuy_repo_create.json; elif [ "$STATUS" != "200" ]; then cat /tmp/oopbuy_repo_check.json >&2; exit 1; fi
git init -q
git branch -M main
git config user.name "$OWNER"
git config user.email "$OWNER@users.noreply.github.com"
git add .
if ! git diff --cached --quiet; then git commit -m "Deploy OopBuy Spreadsheet site"; fi
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$OWNER/$REPO.git"
git push -u origin main --force
git remote set-url origin "https://github.com/$OWNER/$REPO.git"
PAGES_STATUS=$(curl -sS -o /tmp/oopbuy_pages_check.json -w '%{http_code}' -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" "https://api.github.com/repos/$OWNER/$REPO/pages")
if [ "$PAGES_STATUS" = "404" ]; then curl -fsS -X POST -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" "https://api.github.com/repos/$OWNER/$REPO/pages" -d '{"source":{"branch":"main","path":"/"}}' >/tmp/oopbuy_pages_create.json; elif [ "$PAGES_STATUS" = "200" ]; then curl -fsS -X PUT -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" "https://api.github.com/repos/$OWNER/$REPO/pages" -d '{"source":{"branch":"main","path":"/"}}' >/tmp/oopbuy_pages_update.json; else cat /tmp/oopbuy_pages_check.json >&2; exit 1; fi
echo "Done: $BASE/"

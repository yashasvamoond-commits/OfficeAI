#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC_DIR="${1:-}"
OUT_APK="${2:-$ROOT/OfficeCLI-Library.apk}"
TOOLS_DIR="${ANDROID_TOOLS_DIR:-/tmp/android-tools}"
BUILD_DIR="${ANDROID_BUILD_DIR:-$(mktemp -d)}"
JAVA="${JAVA:-java}"
KEYTOOL="${KEYTOOL:-keytool}"

if [[ -z "$SRC_DIR" || ! -f "$SRC_DIR/README.md" ]]; then
  echo "Usage: $0 /path/to/OfficeCLI [output.apk]" >&2
  exit 2
fi
APKTOOL_JAR="$TOOLS_DIR/node_modules/@postar/apktool-node/lib/apktool.jar"
APKSIGNER_JAR="$TOOLS_DIR/node_modules/@postar/apktool-node/lib/apksigner.jar"
[[ -f "$APKTOOL_JAR" && -f "$APKSIGNER_JAR" ]] || { echo "Install @postar/apktool-node under $TOOLS_DIR" >&2; exit 2; }

APP_BUILD="$BUILD_DIR/app"
mkdir -p "$APP_BUILD"
cp -R "$ROOT/android-app/AndroidManifest.xml" "$ROOT/android-app/apktool.yml" "$ROOT/android-app/smali" "$ROOT/android-app/assets" "$APP_BUILD/"
mkdir -p "$APP_BUILD/assets"
# Bundle the upstream project's README as an offline reference. Markdown remains source-safe;
# the companion landing page itself is static and works without network access.
cp "$SRC_DIR/README.md" "$APP_BUILD/assets/OfficeCLI-README.md"
# Bundle the primary source, schemas, agent skills, SDKs, examples/docs, and legal notices.
# Large visual showcase assets and binary example documents are omitted to keep the APK practical.
SOURCE_ZIP="$APP_BUILD/assets/OfficeCLI-source.zip"
(
  cd "$SRC_DIR"
  zip -q -r "$SOURCE_ZIP" \
    .github src schemas skills sdk npm plugins \
    README.md README_ja.md README_ko.md README_zh.md SKILL.md \
    CONTRIBUTING.md CONTRIBUTING.zh.md LICENSE NOTICE SECURITY.md THIRD-PARTY-NOTICES.txt \
    build.sh install.sh install.ps1 dev-install.sh
  # Keep human-readable example scripts and guides, but omit large sample Office files and media.
  find examples -type f \
    \( -name '*.md' -o -name '*.py' -o -name '*.sh' -o -name '*.json' \) -print0 |
    while IFS= read -r -d '' file; do zip -q "$SOURCE_ZIP" "$file"; done
)
# Convert the full upstream README to a self-contained offline HTML guide.
node - "$SRC_DIR/README.md" "$APP_BUILD/assets/OfficeCLI-README.html" "$TOOLS_DIR/node_modules/marked/lib/marked.umd.js" <<'NODE'
const fs = require('fs');
const vm = require('vm');
const [input, output, markedPath] = process.argv.slice(2);
const context = { exports: {}, module: { exports: {} }, globalThis: {} };
vm.runInNewContext(fs.readFileSync(markedPath, 'utf8'), context);
const marked = context.marked || context.exports.marked || context.module.exports.marked;
const markdown = fs.readFileSync(input, 'utf8');
const body = marked.parse(markdown, { gfm: true });
const html = `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>OfficeCLI README</title><style>body{max-width:900px;margin:24px auto;padding:0 18px;background:#07111f;color:#e7eef8;font:16px/1.65 system-ui,sans-serif}a{color:#75d8d0}pre,code{background:#0d1b2b;border-radius:6px}pre{padding:14px;overflow:auto}img{max-width:100%;height:auto}table{border-collapse:collapse;display:block;overflow:auto}td,th{border:1px solid #33445a;padding:7px}blockquote{border-left:3px solid #50cabb;padding-left:14px;color:#b3c2d4}h1,h2,h3{line-height:1.2}</style></head><body>${body}</body></html>`;
fs.writeFileSync(output, html);
NODE

UNSIGNED="$BUILD_DIR/OfficeCLI-Library-unsigned.apk"
mkdir -p "$(dirname "$OUT_APK")"
"$JAVA" -jar "$APKTOOL_JAR" b "$APP_BUILD" -o "$UNSIGNED" -f

KEYSTORE="${APK_KEYSTORE:-$BUILD_DIR/officecli-library-release.jks}"
STOREPASS="${APK_KEYSTORE_PASSWORD:-officecli-local-build}"
ALIAS="${APK_KEY_ALIAS:-officecli-library}"
if [[ ! -f "$KEYSTORE" ]]; then
  "$KEYTOOL" -genkeypair -keystore "$KEYSTORE" -storepass "$STOREPASS" -keypass "$STOREPASS" \
    -alias "$ALIAS" -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=OfficeCLI Library, O=OfficeAI, C=IN" >/dev/null 2>&1
fi
"$JAVA" -jar "$APKSIGNER_JAR" sign --ks "$KEYSTORE" --ks-pass "pass:$STOREPASS" \
  --key-pass "pass:$STOREPASS" --ks-key-alias "$ALIAS" --out "$OUT_APK" "$UNSIGNED"
"$JAVA" -jar "$APKSIGNER_JAR" verify --verbose "$OUT_APK"
echo "Built: $OUT_APK"

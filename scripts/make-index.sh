#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
REPO_URL="${REPO_URL:-https://wozhiainaizi.github.io/}"; mkdir -p debs
command -v apt-ftparchive >/dev/null 2>&1 || { echo "缺少 apt-ftparchive"; exit 1; }
DEBS_ABS="$ROOT/debs"
if apt-ftparchive packages "$DEBS_ABS" >/dev/null 2>&1; then
  apt-ftparchive packages "$DEBS_ABS" | sed "s#^Filename: .*/#Filename: debs/#" > Packages
else
  SCAN="$(mktemp -d)/debs"; mkdir -p "$SCAN"; cp -f "$DEBS_ABS"/*.deb "$SCAN"/ 2>/dev/null || true
  apt-ftparchive packages "$SCAN" | sed "s#^Filename: .*/#Filename: debs/#" > Packages
fi
[ -f overrides.json ] && command -v python3 >/dev/null 2>&1 && python3 scripts/apply-overrides.py
gzip -9 -kf Packages
gen_hashes(){ local alg="$1"; shift; local f; for f in "$@"; do [ -f "$f" ] || continue;
  local size; size=$(wc -c < "$f" | tr -d ' '); local h;
  case "$alg" in md5) h=$(md5sum "$f"|awk '{print $1}');; sha256) h=$(sha256sum "$f"|awk '{print $1}');; esac
  printf ' %s  %s %s\n' "$h" "$size" "$f"; done; }
{ echo "Origin: 暗影大人"; echo "Label: 暗影大人"; echo "Suite: stable"; echo "Version: 1.0";
  echo "Codename: ios"; echo "Architectures: iphoneos-arm64 iphoneos-arm64e"; echo "Components: main";
  echo "Description: 暗影大人 的越狱软件源"; echo "Support: https://wozhiainaizi.github.io/";
  echo "MD5Sum:"; gen_hashes md5 Packages Packages.gz; echo "SHA256:"; gen_hashes sha256 Packages Packages.gz; } > Release

# ---- 固定主页：每次重建强制生成，防止被外部模板覆盖 ----
cat > index.html <<'HTML'
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>暗影大人 的越狱软件源</title>
<style>body{font-family:-apple-system,BlinkMacSystemFont,sans-serif;background:#0d1117;color:#e6edf3;margin:0;padding:30px 16px;text-align:center}
h1{font-size:24px}.sub{color:#8b949e;font-size:14px;margin:8px 0 24px}.sub2{color:#8b949e;font-size:13px;margin:-16px 0 24px}
.btn{display:inline-block;padding:12px 20px;margin:6px;border-radius:12px;background:#1f6feb;color:#fff;text-decoration:none;font-weight:600}
.url{color:#58a6ff;font-size:13px;margin-top:24px;word-break:break-all}</style></head>
<body><h1>暗影大人</h1><div class="sub">万物皆为我所用</div><div class="sub2">RootHide 专用 · Sileo / Zebra 通用</div>
<a class="btn" href="sileo://source/https%3A%2F%2Fwozhiainaizi.github.io%2F">在 Sileo 中打开</a>
<a class="btn" href="zbra://sources/add/https%3A%2F%2Fwozhiainaizi.github.io%2F">在 Zebra 中打开</a>
<div class="url">https://wozhiainaizi.github.io/</div></body></html>
HTML

# ---- 固定图标：从 assets 母本恢复，防止被清空 ----
if [ -f assets/CydiaIcon.png ]; then
  cp -f assets/CydiaIcon.png CydiaIcon.png
fi

echo "索引完成: $(grep -c '^Package:' Packages) 个包"

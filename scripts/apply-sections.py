#!/usr/bin/env python3
"""构建时保留仓库已有分组（Section），避免 apt-ftparchive 重建 Packages 时把
一键建源等工具修改的分组覆盖回 deb 原始值。

用法：make-index.sh 在重建 Packages 前把旧 Packages 存到 $PREV_PACKAGES，
本脚本读取该文件提取 {Package: Section} 映射，覆盖新 Packages 对应包的 Section。
"""
import os
import re
import sys


def parse(path):
    """解析 Packages 文本 → {package_id: section}"""
    with open(path, encoding="utf-8", errors="ignore") as f:
        text = f.read()
    out = {}
    for block in re.split(r"\n\n+", text):
        pid = re.search(r"^Package:\s*(.+)$", block, re.M)
        sec = re.search(r"^Section:\s*(.+)$", block, re.M)
        if pid and sec:
            out[pid.group(1).strip()] = sec.group(1).strip()
    return out


def main():
    prev_path = os.environ.get("PREV_PACKAGES", "")
    if not prev_path or not os.path.exists(prev_path):
        print("分组保留: 无旧 Packages，跳过")
        return
    prev = parse(prev_path)
    if not prev:
        print("分组保留: 旧 Packages 无有效分组，跳过")
        return

    with open("Packages", encoding="utf-8", errors="ignore") as f:
        text = f.read()

    # 按分隔符切块，只改含 Package 的块，保持其它字节不变
    parts = re.split(r"(\n\n+)", text)

    def fix_block(block):
        m = re.search(r"^Package:\s*(.+)$", block, re.M)
        if not m:
            return block
        pid = m.group(1).strip()
        if pid not in prev:
            return block
        new_sec = "Section: " + prev[pid]
        if re.search(r"^Section:\s*.+$", block, re.M):
            return re.sub(r"^Section:\s*.+$", new_sec, block, count=1, flags=re.M)
        # 没有 Section 行：插到 Package 行之后
        return re.sub(r"^(Package:\s*.+)$", r"\1\n" + new_sec, block, count=1, flags=re.M)

    fixed = "".join(fix_block(b) for b in parts)

    with open("Packages", "w", encoding="utf-8") as f:
        f.write(fixed)

    kept = sum(1 for pid in prev if re.search(r"^Package:\s*" + re.escape(pid) + r"\s*$", fixed, re.M))
    print("分组保留完成: %d 个包沿用已有 Section" % kept)


if __name__ == "__main__":
    main()

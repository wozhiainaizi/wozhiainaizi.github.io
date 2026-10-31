#!/usr/bin/env python3
"""分组（Section）控制脚本，两种模式：

1. 权威模式（默认）：仓库根目录存在 sections.json 时，以它为唯一分组来源——
   sections.json 里列出的包按映射设置 Section，其余所有包统一归为「其他」。
   这样分组完全由文件控制，apt-ftparchive 重建、工具修改都不会覆盖。

2. 保留模式（无 sections.json 时）：读取 $PREV_PACKAGES（构建前的旧 Packages）
   提取 {Package: Section} 映射，把旧分组覆盖到新 Packages，防止工具改的分组
   被 apt-ftparchive 用 deb 原始值覆盖。
"""
import json
import os
import re

# Sileo 分类展示顺序（把「其他」排最后，必装在中间）
SECTION_ORDER = ["1 优先安装", "2 越狱必装", "3 插件依赖", "4 其他"]


def parse_prev(path):
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


def apply_mapping(mapping, default_section=None, section_order=None):
    """按 mapping({pid: section}) 重写 Packages；未列出的包按 default_section 处理。
    传入 section_order 时按 Section 稳定重排包块顺序（同组保持原相对顺序）。"""
    with open("Packages", encoding="utf-8", errors="ignore") as f:
        text = f.read()
    parts = re.split(r"(\n\n+)", text)
    entries = []
    i = 0
    while i < len(parts):
        block = parts[i]
        sep = parts[i + 1] if i + 1 < len(parts) else ""
        i += 2
        m = re.search(r"^Package:\s*(.+)$", block, re.M)
        if m:
            pid = m.group(1).strip()
            new_sec = None
            if pid in mapping:
                new_sec = "Section: " + mapping[pid]
            elif default_section is not None:
                new_sec = "Section: " + default_section
            if new_sec is not None:
                if re.search(r"^Section:\s*.+$", block, re.M):
                    block = re.sub(r"^Section:\s*.+$", new_sec, block, count=1, flags=re.M)
                else:
                    block = re.sub(r"^(Package:\s*.+)$", r"\1\n" + new_sec, block, count=1, flags=re.M)
        sm = re.search(r"^Section:\s*(.+)$", block, re.M)
        sec = sm.group(1).strip() if sm else ""
        entries.append((sec, block, sep))
    if i < len(parts):  # 尾部残余元素
        entries.append(("", parts[i], ""))
    if section_order:
        order = {s: idx for idx, s in enumerate(section_order)}
        entries.sort(key=lambda e: order.get(e[0], len(order)))
    fixed = "".join(b + s for _, b, s in entries)
    with open("Packages", "w", encoding="utf-8") as f:
        f.write(fixed)
    return sum(1 for pid in mapping if re.search(r"^Package:\s*" + re.escape(pid) + r"\s*$", fixed, re.M))


def main():
    # 权威模式：sections.json 存在即优先
    if os.path.exists("sections.json"):
        with open("sections.json", encoding="utf-8") as f:
            mapping = json.load(f)
        kept = apply_mapping(mapping, default_section="4 其他", section_order=SECTION_ORDER)
        print("分组控制: sections.json 生效，%d 个包自定义分组，其余归「4 其他」" % kept)
        return

    # 保留模式
    prev_path = os.environ.get("PREV_PACKAGES", "")
    if not prev_path or not os.path.exists(prev_path):
        print("分组保留: 无旧 Packages，跳过")
        return
    prev = parse_prev(prev_path)
    if not prev:
        print("分组保留: 旧 Packages 无有效分组，跳过")
        return
    kept = apply_mapping(prev)
    print("分组保留完成: %d 个包沿用已有 Section" % kept)


if __name__ == "__main__":
    main()

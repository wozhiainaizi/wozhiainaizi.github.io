# apps 目录

本站另外分发的第三方应用安装包（与 `debs/` 的 Sileo 插件包相互独立，不参与源索引构建）。

## 文析助手 / asterlink

- **项目地址**：<https://github.com/z7786/wenxi>
- **项目简介**：跨平台聚合网盘解析与管理软件，支持 17 家主流网盘，已覆盖 Android / iOS / Windows / macOS
- **许可**：GNU AGPL-3.0-or-later（源码见本项目 Releases 中的 source 包）

### 文件

| 文件 | 版本 | 大小 | SHA-256 |
|---|---|---|---|
| `asterlink-2.2.0+220-ios-arm64-unsigned.ipa` | v2.2.0+220 | 34.1 MB | `7e69391a25dcf8378c2762219cc63b549b0e3446cb01282f4a0342d32dd7adb2` |
| `wenxi-v2.3.0+230-source.zip`（Release 附件） | v2.3.0+230 | 122.7 MB | `aa9787f4b3e4d93936f31797a62849cc41ce7834ba67ad2004ee7fc7d3f54457` |

### 安装说明（iOS）

该 IPA 为 **未签名包**，不能直接用 App Store / AltStore 安装，需使用 **TrollStore（巨魔）** 安装：

1. 下载 `.ipa` 到手机（可用 Safari 直接存到「文件」）
2. 打开 TrollStore，点右上角 `+`，选择该 ipa
3. 安装完成后首次启动若提示不受信任，回 TrollStore 里点一次该应用条目刷新签名

未越狱的设备无法安装未签名 IPA。

### 说明

- 文件从上游 Releases 原样下载，未做任何修改；SHA-256 与上游公布值一致（ipa 已逐个比对）
- 上游最新版 **v2.3.0+230 只发布了源码，没有编译产物**，因此 iOS 安装包仍是 v2.2.0+220
- 本目录仅作备份与分发，应用版权归原作者 `z7786` 所有，问题请到上游 Issues 反馈

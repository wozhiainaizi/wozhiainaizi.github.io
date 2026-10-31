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
{ echo "Origin: - 暗影大人"; echo "Label: - 暗影大人"; echo "Suite: stable"; echo "Version: 1.0";
  echo "Codename: ios"; echo "Architectures: iphoneos-arm64 iphoneos-arm64e"; echo "Components: main";
  echo "Description: 暗影大人 的越狱软件源"; echo "Support: https://wozhiainaizi.github.io/";
  echo "MD5Sum:"; gen_hashes md5 Packages Packages.gz; echo "SHA256:"; gen_hashes sha256 Packages Packages.gz; } > Release

# ---- 固定主页：每次重建强制生成，防止被外部模板覆盖 ----
cat > index.html <<'HTML'
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>暗影大人 的越狱软件源</title>
<style>
*{box-sizing:border-box}
body{font-family:-apple-system,BlinkMacSystemFont,"PingFang SC",sans-serif;background:#0d1117;color:#e6edf3;margin:0}
.hero{width:100%;max-height:420px;overflow:hidden}
.hero img{width:100%;height:auto;display:block;object-fit:cover;max-height:420px}
main{padding:20px 16px 48px;max-width:720px;margin:0 auto}
h1{font-size:24px;margin:0;text-align:center}.sub{color:#8b949e;font-size:14px;margin:8px 0 22px;text-align:center}
.btns{text-align:center;margin-bottom:22px}
.btn{display:inline-block;padding:11px 18px;margin:5px;border-radius:12px;background:#1f6feb;color:#fff;text-decoration:none;font-weight:600;font-size:14px}
.nav{display:flex;flex-wrap:nowrap;gap:8px;overflow-x:auto;padding:4px 2px 10px;-webkit-overflow-scrolling:touch}
.chip{flex:0 0 auto;padding:8px 14px;border-radius:999px;background:#161b22;border:1px solid #30363d;color:#8b949e;font-size:13px;cursor:pointer;user-select:none}
.chip.on{background:#1f6feb;border-color:#1f6feb;color:#fff;font-weight:600}
.count{font-size:11px;opacity:.75;margin-left:4px}
.hint{color:#484f58;font-size:12px;margin:2px 0 12px}
.card{background:#161b22;border:1px solid #21262d;border-radius:12px;padding:12px 14px;margin-bottom:10px;cursor:pointer}
.card b{font-size:15px;color:#e6edf3;display:block}
.tag{display:inline-block;font-size:11px;color:#58a6ff;background:rgba(88,166,255,.12);border-radius:6px;padding:2px 7px;margin-top:6px}
.card p{font-size:13px;color:#8b949e;margin:6px 0 0;line-height:1.45}
#toast{position:fixed;left:50%;bottom:32px;transform:translateX(-50%);background:#30363d;color:#e6edf3;padding:9px 16px;border-radius:10px;font-size:13px;opacity:0;transition:opacity .25s;pointer-events:none;max-width:86vw;text-align:center}
#toast.show{opacity:1}
@media(min-width:768px){.card{padding:14px 18px}.card b{font-size:16px}}
</style></head>
<body><div class="hero"><img src="assets/hero.jpg" alt="暗影大人 源横幅"></div><main>
<h1>暗影大人</h1><div class="sub">万物皆为我所用 · RootHide 专用 · Sileo / Zebra 通用</div>
<div class="btns">
<a class="btn" href="sileo://source/https%3A%2F%2Fwozhiainaizi.github.io%2F">在 Sileo 中打开</a>
<a class="btn" href="zbra://sources/add/https%3A%2F%2Fwozhiainaizi.github.io%2F">在 Zebra 中打开</a>
</div>
<div class="nav" id="nav"></div>
<div class="hint" id="hint">共 105 个软件包，点分组筛选，点卡片查看说明</div>
<div id="list"></div>
<div id="toast"></div>
<script>
const DATA=[{"n": "RainFlow 120Hz", "g": "界面美化", "d": "专注核心 80Hz/120Hz 调度的精简方案；适合不需要 Pro 扩展功能、注重流"}, {"n": "AirDrop", "g": "系统工具", "d": "解除隔空投送十分钟限制，支持设置自定义关闭时间，4秒内控制中心隔空投送连续点击两次所"}, {"n": "Allow Network-Rootless", "g": "系统工具", "d": "国行手机自动允许使用网络。"}, {"n": "AppStoreTroller", "g": "破解增强", "d": "伪装成合适的iOS版本，并获取需高iOS版本的应用。"}, {"n": "BetterAlarm 中文版", "g": "界面美化", "d": "漂亮的定时器和闹钟提醒，根据开源编译。"}, {"n": "CCDND", "g": "界面美化", "d": "控制中心勿扰模式单模块。"}, {"n": "CCSupport 真后台", "g": "快捷效率", "d": "点开一个APP，控制中心点击按钮即可"}, {"n": "CPU 解除温控", "g": "系统工具", "d": "适配 iOS 15–17 的用户态预算实验。解除温控请求 CPU/GPU/Packa"}, {"n": "CPU Free", "g": "系统工具", "d": "一个强大的 iOS 温控管理插件，接管系统温控决策，让 iPhone 发热时不再被强"}, {"n": "Choicy", "g": "运行环境", "d": "Advanced Tweak Configuration!"}, {"n": "Choicy Patch", "g": "运行环境", "d": "给Choicy增加已设置置顶 / 进程页面本地缓存。(支持iOS 15-17)"}, {"n": "CocoaTop64 中文版", "g": "系统工具", "d": "CocoaTop64 进程查看，基于真皮版定制：中文翻译+UI微调+更新图标等。"}, {"n": "ElleKit", "g": "运行环境", "d": "ElleKit tweak injection libraries and load"}, {"n": "EvoCenter16 控制中心", "g": "界面美化", "d": "A modern, resizable and highly customizabl"}, {"n": "FreePIP 画中画增强", "g": "影音播放", "d": "系统画中画功能增强，基于开源，优化了一些代码，改进了一些细节，长按画中画窗口切换模式"}, {"n": "ios16~17 动态岛", "g": "界面美化", "d": "一款市面上最优秀、功能最完整、最稳定的灵动岛插件。集成授权校验联系:VCR66T"}, {"n": "HelloMnt", "g": "运行环境", "d": "Relaxin 挂载器!"}, {"n": "Hello 3Q", "g": "运行环境", "d": "别在后台热加载app咯!"}, {"n": "IPSLog", "g": "系统工具", "d": "设置内一键查看与分析设备上的 .ips 崩溃日志，快速定位崩溃原因。"}, {"n": "InstaLauncher 2 快捷应用", "g": "快捷效率", "d": "Launch ANY app instantly 通过插件激活出来的侧边栏，可以快速"}, {"n": "Legacy arm64e Support", "g": "运行环境", "d": "Support for legacy arm64e ABI in iOS 15.0+"}, {"n": "Mikkyy 主題管理", "g": "界面美化", "d": "Modern, lightweight theme engine for iOS 1"}, {"n": "No Apple MobileRepair 禁止在设置页面显示维修记录", "g": "其他", "d": "No Apple MobileRepair"}, {"n": "No Redirect 禁止跳转", "g": "其他", "d": "Stop specified apps from redirecting to Ap"}, {"n": "Orion (iOS 14-17)", "g": "运行环境", "d": "Runtime for tweaks built using Orion and S"}, {"n": "PopOutButtons 按钮动画", "g": "界面美化", "d": "本插件功能：让你的音量键和电源键每按一次，在手机屏幕里显示动画效果，这是模仿iOS1"}, {"n": "PreferenceLoader", "g": "运行环境", "d": "load preferences in style"}, {"n": "ProMotion 120Hz", "g": "界面美化", "d": "High-refresh policy tweak for supported iP"}, {"n": "RecordAnywhere 锁屏录屏", "g": "影音播放", "d": "使手机在锁屏状态也可以继续录屏。修复支持Dopamine，感谢原作者提供的思路。"}, {"n": "Satella 内购破解", "g": "破解增强", "d": "牛X的应用内购买破解器，具体效果预览截图"}, {"n": "ScreenCore", "g": "其他", "d": "分屏而已"}, {"n": "SharingdAlertWatchdog", "g": "系统工具", "d": "各位开发者是否遇到了 Airdrop 投送后，移动端无法出现菜单，界面卡住崩溃？那试"}, {"n": "SmoothInstall", "g": "运行环境", "d": "简化roothide越狱安装rootless插件时的流程"}, {"n": "SneakyCam 隐私相机", "g": "其他", "d": "Native SneakyCam capture build for iOS 15."}, {"n": "StayShot", "g": "影音播放", "d": "StayShot 独立的 iOS 截图工具，支持普通模式、冻结模式、区域截图、截图历"}, {"n": "StayShot Edit", "g": "影音播放", "d": "StayShot Edit 的冻结截图编辑扩展，支持箭头、涂鸦、高亮、马赛克和方框，"}, {"n": "StayShot Long Screenshot", "g": "影音播放", "d": "Long screenshot action and capture control"}, {"n": "SuSuOCR", "g": "快捷效率", "d": "内置百度 OCR、GLM 和 Qwen 流式普通翻译；保留自定义 OCR、百度翻译及"}, {"n": "TVLock", "g": "界面美化", "d": "很棒的老电视关屏动画，根据开源编译，已内置简体中文。"}, {"n": "ThemeCore", "g": "界面美化", "d": "轻量化桌面图标主题插件，修改图标及图标阴影如此轻松，覆盖绝大部分区域，时钟日历可动态"}, {"n": "TrollCM", "g": "其他", "d": "显示屏幕触摸轨迹，支持iOS14-17所有越狱"}, {"n": "TrollOpen", "g": "运行环境", "d": "内置离线版，在16系统隐根状态测试正常，其他系统自测。"}, {"n": "TrollRecorder JB", "g": "系统工具", "d": "Record your phone calls like never before."}, {"n": "TrollStore Lite 白巨魔", "g": "系统工具", "d": "A modified TrollStore by iosdump for jailb"}, {"n": "TweaksHub", "g": "快捷效率", "d": "集中收纳统一管理越狱插件与第三方 App 设置，支持插件自定义名称和图标。"}, {"n": "Unseen", "g": "界面美化", "d": "Neutralizes CALayer disableUpdateMask in t"}, {"n": "AntiDarkSword", "g": "系统工具", "d": "Security framework to defend against WebKi"}, {"n": "AppData 应用数据", "g": "系统工具", "d": "AppData在桌面图标上滑动或长按菜单呼出面板，查看并管理任意应用的沙盒数据、权限"}, {"n": "Auto Copy Verify", "g": "快捷效率", "d": "自动复制短信、系统邮件、部分主流第三方邮件的验证码到剪切板，第三方邮件只能从临时通知"}, {"n": "URL管家-隐根", "g": "快捷效率", "d": "URL管家（RootHide 版）— 统一接管本机 URL Scheme（隐藏 / "}, {"n": "Hello 120Hz", "g": "界面美化", "d": ""}, {"n": "Hello Memory Status", "g": "系统工具", "d": "Set memorystatus to avoid being killed by "}, {"n": "Hello QActions", "g": "快捷效率", "d": "通过锁屏界面的手电筒和相机快速调用指定APP快捷操作，体验一键直达。"}, {"n": "Hello QuickPanel", "g": "快捷效率", "d": "快捷面板~"}, {"n": "ScreenShell Pro", "g": "影音播放", "d": "专业的 iOS 全局水印&套壳『截屏.录屏』增强工具。插件需要授权才能使用。授权请联"}, {"n": "floatingView", "g": "其他", "d": "分屏，不必太复杂，一切从简即可。"}, {"n": "VolumeManager 音量管理", "g": "系统工具", "d": "音量管理，就是这么简单。包含功能：混响、多元化音量。本插件可以给每个APP单独设置音"}, {"n": "Adytum", "g": "系统工具", "d": "True application backgrounding management."}, {"n": "CopyVault", "g": "快捷效率", "d": "Your Copy Vault, Your Pasteboard"}, {"n": "Crane", "g": "系统工具", "d": "Multiple containers for your applications!"}, {"n": "DNDMyRecording", "g": "系统工具", "d": "Enable DND when a screen recording is init"}, {"n": "DynamicFX", "g": "界面美化", "d": "灵动岛背景？"}, {"n": "DynamicNotLand 隐藏灵动岛", "g": "界面美化", "d": "在 14 Pro 系列上，隐藏未使用时的灵动岛，有些有强迫症的人有此需求，能理解但不"}, {"n": "Filza Crack", "g": "破解增强", "d": "Filza解锁全部功能，请在官方源安装Filza。Netskao新更的版本，上架备份"}, {"n": "iCleaner Pro 系统清理正版", "g": "系统工具", "d": "iOS系统 垃圾清理 & 插件管理工具，此版本为正版，需搭配iCleanerPro【"}, {"n": "iCleanerPro 系统清理破解补丁", "g": "破解增强", "d": "iCleaner Pro破解全功能插件，此补丁搭配正版iCleaner Pro使用，"}, {"n": "HelloBundleID", "g": "系统工具", "d": "伪装越狱和巨魔应用，让商店应用更难检测越狱!"}, {"n": "Immortalizer", "g": "系统工具", "d": "Foreground your apps even if they are in t"}, {"n": "insulation", "g": "系统工具", "d": "解除温控，一切从简即可。支持命令行切换模式：ins off（原生温控）/ ins l"}, {"n": "libSandy", "g": "运行环境", "d": "Securely extend the sandbox of system proc"}, {"n": "灵动岛跳舞动画", "g": "界面美化", "d": "用于灵动岛专辑及屏幕录制动态跳舞动画整合，只支持有灵动岛的用户，大家自行测试，灵动半"}, {"n": "SnowBoard Icon Masks Extension", "g": "界面美化", "d": "Icon masks for SnowBoard"}, {"n": "MemTrim", "g": "系统工具", "d": "优化并释放部分运行内存。(支持iOS 15-17)"}, {"n": "NoPassAfterRespring 注销不锁屏", "g": "其他", "d": "Disables passcode after a respring. This v"}, {"n": "OneSettings", "g": "界面美化", "d": "设置美化，插件归类"}, {"n": "PanCake 简体中文包", "g": "其他", "d": "PanCake 简体中文包(rootless)。"}, {"n": "PanCake", "g": "其他", "d": "Interactive dismiss gesture on the whole s"}, {"n": "相册增强", "g": "其他", "d": "自用备份。"}, {"n": "原生键盘高度调整", "g": "快捷效率", "d": "自定义X键盘底部高度，地球底部高度等，非常不错的一个插件，键盘低了，用起来很舒服，搬"}, {"n": "PullClearNC 清理通知", "g": "其他", "d": "轻量级下拉清理通知，通知栏快速下拉即可清理"}, {"n": "PleaseDontStopTheMusic 请别暂停音乐", "g": "影音播放", "d": "Prevent apps (e.g. Roblox) from pausing yo"}, {"n": "PyVideo", "g": "影音播放", "d": "获取当前页面的视频并下载，仅Safari浏览器可用；无设置项。（支持iOS 15-1"}, {"n": "QuickPrefs", "g": "快捷效率", "d": "Quickly access settings prefs from 3D Touc"}, {"n": "彩虹键盘光效", "g": "界面美化", "d": "三星风格彩虹键盘光效，重写版，支持 arm64e 系统进程注入，含设置页"}, {"n": "rootless-compat", "g": "运行环境", "d": "Compat Layer for Rootless Tweaks"}, {"n": "SafariExploitGuard", "g": "系统工具", "d": "Coruna / DarkSword 漏洞利用拦截防护插件"}, {"n": "SettingsWidgets小组件", "g": "界面美化", "d": ""}, {"n": "SHELLX", "g": "影音播放", "d": "支持录屏/截图套壳，水印以及区域截图、长截图、Ai问答、快捷手势等，兼容iOS14-"}, {"n": "ShortBar", "g": "界面美化", "d": "让小白条缩短的轻量插件 (支持iOS 15-17)"}, {"n": "Snapper 3", "g": "其他", "d": "Pin screenshots on the screen."}, {"n": "Snapper3 霓虹蓝发光效果主题", "g": "界面美化", "d": "季伯仰备份"}, {"n": "SnowBoard", "g": "界面美化", "d": "Snowboard theming engine"}, {"n": "split-view-pro", "g": "其他", "d": "分屏，不必太复杂，一切从简即可。"}, {"n": "SquidExtender", "g": "快捷效率", "d": "Extend your keyboard to be more POWERFULL!"}, {"n": "SquidGesture Pro", "g": "快捷效率", "d": "Gestures"}, {"n": "StayAlive Lite", "g": "系统工具", "d": "轻量后台守护插件，支持多种运行方式与任务角色性能控制，让app后台运行更稳定。(支持"}, {"n": "Stella 中文版", "g": "界面美化", "d": "让你的设备在主屏/锁屏上下雪！根据开源，定制的中文版。"}, {"n": "SurgeActive", "g": "其他", "d": "锁屏时保持 Surge-iOS-NE 的活跃性。(支持iOS 15-17)"}, {"n": "TapLink", "g": "快捷效率", "d": "通过悬浮触发点，将点击映射到指定位置，内置多种触发结果。(支持iOS 15-17)"}, {"n": "Vitreux 液态玻璃", "g": "界面美化", "d": "1.主打 iOS 26 系统液态玻璃设计。2.让旧系统体验液态玻璃风格。3.目前版本"}, {"n": "Voidy 简体中文语言包", "g": "其他", "d": "Simplified Chinese localization for Voidy."}, {"n": "Voidy", "g": "系统工具", "d": "Lightweight system cleaner for rootless an"}, {"n": "ZombieReaper 清理子进程", "g": "系统工具", "d": "Auto-reap zombie child processes for Sprin"}, {"n": "灵动通知iOS16-正式版(RootHide)", "g": "界面美化", "d": "完美的使用原生灵动岛展示系统通知等..."}, {"n": "电话助手iOS16-正式版(Roothide)", "g": "系统工具", "d": "电话助手授权版本,通话录音,通话记录合并,T9双卡选卡拨号键盘,短信双卡选卡,来去电"}];
const GROUPS=["全部","系统工具","界面美化","影音播放","破解增强","快捷效率","运行环境","其他"];
const count=g=>DATA.filter(x=>x.g===g).length;
const nav=document.getElementById('nav');
nav.innerHTML=GROUPS.map((g,i)=>'<div class="chip'+(i===0?' on':'')+'" data-g="'+g+'">'+g+'<span class="count">'+(g==="全部"?DATA.length:count(g))+'</span></div>').join('');
const list=document.getElementById('list'),hint=document.getElementById('hint'),toast=document.getElementById('toast');
function render(g){
  const items=g==="全部"?DATA:DATA.filter(x=>x.g===g);
  list.innerHTML=items.map(x=>'<div class="card" data-n="'+x.n+'"><b>'+x.n+'</b><span class="tag">'+x.g+'</span>'+(x.d?'<p>'+x.d+'</p>':'')+'</div>').join('');
  hint.textContent=g==="全部"?('共 '+items.length+' 个软件包，点分组筛选'):('分组「'+g+'」共 '+items.length+' 个软件包');
}
render("全部");
nav.addEventListener('click',e=>{const c=e.target.closest('.chip');if(!c)return;
  nav.querySelectorAll('.chip').forEach(x=>x.classList.remove('on'));c.classList.add('on');render(c.dataset.g);});
list.addEventListener('click',e=>{const c=e.target.closest('.card');if(!c)return;
  toast.textContent=c.dataset.n+'：安装请添加本源后搜索，或回复本插件名获取指引';toast.classList.add('show');
  clearTimeout(toast._t);toast._t=setTimeout(()=>toast.classList.remove('show'),1800);});
</script></main></body></html>
HTML

# ---- 固定图标：从 assets 母本恢复，防止被清空 ----
if [ -f assets/CydiaIcon.png ]; then
  cp -f assets/CydiaIcon.png CydiaIcon.png
fi

echo "索引完成: $(grep -c '^Package:' Packages) 个包"

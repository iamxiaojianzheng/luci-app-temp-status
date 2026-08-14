#!/bin/sh
# =========================================================
# One-key Installer for luci-app-temp-status
# Target Repo: https://github.com/iamxiaojianzheng/luci-app-temp-status
# =========================================================

set -e

REPO="iamxiaojianzheng/luci-app-temp-status"
TMP_DIR="/tmp/temp_status_install"

# 终端输出颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO] $1${NC}"; }
log_warn()  { echo -e "${YELLOW}[WARN] $1${NC}"; }
log_error() { echo -e "${RED}[ERROR] $1${NC}"; }

# 1. 系统环境判断
if [ ! -f /etc/openwrt_release ]; then
    log_error "此脚本仅适用于 OpenWrt 系统！"
    exit 1
fi

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# 2. 判断包管理器 (经典 IPK 或 新版 APK)
if command -v apk >/dev/null 2>&1; then
    PKG_TYPE="apk"
    log_info "检测到新版 OpenWrt 包管理器: APK"
elif command -v opkg >/dev/null 2>&1; then
    PKG_TYPE="ipk"
    log_info "检测到经典 OpenWrt 包管理器: IPK (opkg)"
else
    log_error "未检测到可用的包管理器 (opkg/apk)！"
    exit 1
fi

# 3. 安装必要的依赖库
log_info "正在更新包索引并安装运行依赖 (ucode, ucode-mod-fs)..."
if [ "$PKG_TYPE" = "ipk" ]; then
    opkg update || log_warn "opkg update 失败，尝试直接安装..."
    opkg install ucode ucode-mod-fs curl jq || true
else
    apk update || log_warn "apk update 失败，尝试直接安装..."
    apk add ucode ucode-mod-fs curl jq || true
fi

# 4. 获取 GitHub 最新 Release
log_info "正在从 GitHub 获取 $REPO 最新版本..."
RELEASE_JSON=$(curl -sH "User-Agent: OpenWrt-Installer" "https://api.github.com/repos/${REPO}/releases/latest")

if [ -z "$RELEASE_JSON" ] || echo "$RELEASE_JSON" | grep -q "message"; then
    log_error "无法从 GitHub API 获取 Release 信息，请检查网络或 GitHub 连通性！"
    rm -rf "$TMP_DIR"
    exit 1
fi

LATEST_TAG=$(echo "$RELEASE_JSON" | jq -r '.tag_name // empty')
log_info "检测到最新版本: ${LATEST_TAG}"

# 5. 解析并下载对应格式的所有产物包 (主程序包及语言包)
DOWNLOAD_URLS=$(echo "$RELEASE_JSON" | jq -r ".assets[] | select(.name | endswith(\".${PKG_TYPE}\")) | .browser_download_url")

if [ -z "$DOWNLOAD_URLS" ]; then
    log_error "在 Release ${LATEST_TAG} 中未找到扩展名为 .${PKG_TYPE} 的安装包！"
    rm -rf "$TMP_DIR"
    exit 1
fi

log_info "开始下载最新的软件包..."
for url in $DOWNLOAD_URLS; do
    file_name=$(basename "$url")
    log_info "正在下载: $file_name"
    curl -sL "$url" -o "$file_name"
done

# 6. 安装软件包
log_info "正在安装软件包..."
if [ "$PKG_TYPE" = "ipk" ]; then
    opkg install *."$PKG_TYPE"
else
    apk add --allow-untrusted *."$PKG_TYPE"
fi

# 7. 清理临时文件夹
cd /
rm -rf "$TMP_DIR"

# 8. 重启服务生效
log_info "正在重启 rpcd 和 LuCI 服务..."
/etc/init.d/rpcd restart 2>/dev/null || true
if [ -f /etc/init.d/luci ]; then
    /etc/init.d/luci restart 2>/dev/null || true
fi

log_info "================================================="
log_info " 🎉 luci-app-temp-status 安装成功 (${LATEST_TAG})！"
log_info " 请刷新 OpenWrt 页面，前往【状态】->【温度】查看。 "
log_info "================================================="
# luci-app-temp-status
Temperature sensors data for the LuCI status page (OpenWrt webUI).
LuCI状态页面（OpenWrt webUI）的温度传感器数据。

OpenWrt >= 22.03.

**Dependences:** ucode, ucode-mod-fs.

## Installation notes

```ash
wget --no-check-certificate -O /tmp/luci-app-temp-status_0.7.1-r2_all.ipk https://github.com/iamxiaojianzheng/luci-app-temp-status/releases/download/v0.7.1/luci-app-temp-status_0.7.1-r2_all.ipk
opkg install /tmp/luci-app-temp-status_0.7.1-r2_all.ipk
rm /tmp/luci-app-temp-status_0.7.1-r2_all.ipk
service rpcd restart
```

i18n:
```ash
wget --no-check-certificate -O /tmp/luci-i18n-temp-status-zh-cn_25.198.41255.2bcbe17_all.ipk https://github.com/iamxiaojianzheng/luci-app-temp-status/releases/download/v0.7.1/luci-i18n-temp-status-zh-cn_25.198.41255.2bcbe17_all.ipk
opkg install /tmp/luci-i18n-temp-status-zh-cn_25.198.41255.2bcbe17_all.ipk
rm /tmp/luci-i18n-temp-status-zh-cn_25.198.41255.2bcbe17_all.ipk
```

## Screenshots:

<img width="1950" height="314" alt="image" src="https://github.com/user-attachments/assets/c33f4c91-7fc3-4bcd-b5c1-69c232f6c990" />

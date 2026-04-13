# OpenAB K3s 安裝腳本

一鍵安裝 OpenAB 到 Ubuntu + k3s 環境

## 快速開始

在你的 Ubuntu 機器上執行：

```bash
curl -sSL https://raw.githubusercontent.com/Eevee7828/openab-installer/main/install-k3s-openab.sh -o install.sh
chmod +x install.sh
sudo ./install.sh
```

## 功能

- ✅ 自動安裝 k3s（如果未安裝）
- ✅ 自動安裝 Helm（如果未安裝）
- ✅ 互動式輸入 Discord Bot Token 和 Channel ID
- ✅ 部署 OpenAB 到 k3s
- ✅ 提供後續認證步驟說明

## 詳細說明

完整安裝指南請參考 [INSTALL-GUIDE-zh.md](INSTALL-GUIDE-zh.md)

## 關於 OpenAB

OpenAB 是一個輕量級、安全的 ACP harness，連接 Discord 和任何 ACP 相容的 coding CLI（Kiro CLI、Claude Code、Codex、Gemini 等）。

- 官方專案：https://github.com/openabdev/openab
- Helm Chart：https://openabdev.github.io/openab
- Discord 社群：https://discord.gg/YNksK9M6

## License

MIT

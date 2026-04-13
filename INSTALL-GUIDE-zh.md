# OpenAB k3s 安裝指南（新手版）

## 📋 安裝前準備

### 1. 取得 Discord Bot Token

1. 前往 https://discord.com/developers/applications
2. 點擊 "New Application" 建立應用
3. 左側選單 → "Bot" → 點擊 "Add Bot"
4. 啟用 **Message Content Intent**
5. 點擊 "Reset Token" 複製 token（只會顯示一次，請妥善保存）

### 2. 取得 Discord Channel ID

1. Discord 設定 → 進階 → 開啟「開發者模式」
2. 右鍵點擊你想使用的頻道 → "複製頻道 ID"

### 3. 邀請 Bot 到伺服器

1. 回到 Discord Developer Portal
2. OAuth2 → URL Generator
3. 勾選 Scopes: `bot`
4. 勾選 Bot Permissions:
   - Send Messages
   - Send Messages in Threads
   - Create Public Threads
   - Read Message History
   - Add Reactions
   - Manage Messages
5. 複製產生的 URL，在瀏覽器開啟並邀請 bot

---

## 🚀 快速安裝（一鍵腳本）

### 在你的 Ubuntu 機器上執行：

```bash
# 1. 複製安裝腳本到 Ubuntu 機器
# 2. 賦予執行權限
chmod +x install-k3s-openab.sh

# 3. 執行安裝
./install-k3s-openab.sh
```

腳本會自動：
- ✅ 安裝 k3s（如果未安裝）
- ✅ 安裝 Helm（如果未安裝）
- ✅ 詢問你的 Discord Bot Token 和 Channel ID
- ✅ 部署 OpenAB
- ✅ 等待 Pod 啟動

---

## 🔐 首次認證（必須）

安裝完成後，需要進行一次 OAuth 認證：

```bash
# 1. 進入 pod 執行登入
kubectl exec -it deployment/openab-kiro -- kiro-cli login --use-device-flow

# 2. 會顯示一個 URL 和驗證碼，在瀏覽器開啟 URL 並輸入驗證碼

# 3. 認證完成後重啟 pod
kubectl rollout restart deployment/openab-kiro
```

---

## ✅ 驗證安裝

```bash
# 檢查 pod 狀態（應該顯示 Running）
kubectl get pods

# 查看 logs（應該看到 "Connected to Discord"）
kubectl logs -f deployment/openab-kiro
```

---

## 🎮 開始使用

在你設定的 Discord 頻道中：

```
@YourBotName 你好
```

Bot 會自動建立一個 thread 並回覆。之後在 thread 中直接對話即可，不需要再 @mention。

---

## 📝 常用指令

```bash
# 查看所有資源
kubectl get all

# 查看 logs
kubectl logs -f deployment/openab-kiro

# 重啟 pod
kubectl rollout restart deployment/openab-kiro

# 查看 PVC（持久化儲存）
kubectl get pvc

# 完全移除 OpenAB
helm uninstall openab

# 刪除 PVC 和 Secret（可選，會清除認證資料）
kubectl delete pvc openab-kiro
kubectl delete secret openab-kiro
```

---

## 🔧 進階設定

### 修改設定

```bash
# 查看目前設定
helm get values openab

# 更新設定（例如增加 channel）
helm upgrade openab openab/openab \
  --reuse-values \
  --set-string 'agents.kiro.discord.allowedChannels[1]=另一個CHANNEL_ID'
```

### 限制特定使用者

```bash
helm upgrade openab openab/openab \
  --reuse-values \
  --set-string 'agents.kiro.discord.allowedUsers[0]=你的USER_ID'
```

### 使用 values.yaml 檔案（推薦）

建立 `my-values.yaml`：
```yaml
agents:
  kiro:
    discord:
      botToken: "YOUR_BOT_TOKEN"
      allowedChannels:
        - "CHANNEL_ID_1"
        - "CHANNEL_ID_2"
      allowedUsers:  # 可選：限制使用者
        - "USER_ID_1"
    pool:
      maxSessions: 20  # 增加並發數
      sessionTtlHours: 48
```

安裝：
```bash
helm install openab openab/openab -f my-values.yaml
```

更新：
```bash
helm upgrade openab openab/openab -f my-values.yaml
```

---

## ❓ 常見問題

### Pod 一直 Pending？
```bash
# 檢查 PVC 狀態
kubectl describe pvc openab-kiro

# 檢查 pod 詳細資訊
kubectl describe pod -l app.kubernetes.io/instance=openab
```

### Bot 沒有回應？
1. 確認 bot 有在線上（Discord 顯示綠燈）
2. 檢查 logs: `kubectl logs -f deployment/openab-kiro`
3. 確認 channel ID 正確
4. 確認已完成 kiro-cli 認證

### 如何更新到新版本？
```bash
helm repo update
helm upgrade openab openab/openab --reuse-values
```

---

## 📚 更多資訊

- OpenAB GitHub: https://github.com/openabdev/openab
- Helm Chart 文件: https://openabdev.github.io/openab
- Discord 社群: https://discord.gg/YNksK9M6

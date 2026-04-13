#!/bin/bash
set -e

echo "=========================================="
echo "OpenAB + k3s 一鍵安裝腳本"
echo "=========================================="
echo ""

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 檢查是否為 root 或有 sudo 權限
if [ "$EUID" -ne 0 ]; then 
    if ! command -v sudo &> /dev/null; then
        echo -e "${RED}✗ 需要 root 權限或 sudo${NC}"
        exit 1
    fi
    SUDO="sudo"
else
    SUDO=""
fi

# 檢查是否為 root 或有 sudo 權限
if [ "$EUID" -ne 0 ]; then 
    if ! command -v sudo &> /dev/null; then
        echo -e "${RED}✗ 需要 root 權限或 sudo${NC}"
        exit 1
    fi
    SUDO="sudo"
else
    SUDO=""
fi

# ============================================
# 步驟 1: 檢查並安裝必要工具
# ============================================
echo -e "${YELLOW}[1/7] 檢查必要工具...${NC}"

# 檢查 curl
if ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}→ 安裝 curl...${NC}"
    $SUDO apt-get update
    $SUDO apt-get install -y curl
fi

# 檢查 git
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}→ 安裝 git...${NC}"
    $SUDO apt-get update
    $SUDO apt-get install -y git
fi

echo -e "${GREEN}✓ 必要工具已就緒${NC}"

# ============================================
# 步驟 2: 檢查是否已安裝 k3s
# ============================================
echo ""
echo -e "${YELLOW}[2/7] 檢查 k3s...${NC}"
if command -v k3s &> /dev/null; then
    echo -e "${GREEN}✓ k3s 已安裝${NC}"
else
    echo -e "${YELLOW}→ 安裝 k3s...${NC}"
    curl -sfL https://get.k3s.io | sh -
    
    # 等待 k3s 啟動
    echo "等待 k3s 啟動..."
    sleep 10
    
    echo -e "${GREEN}✓ k3s 安裝完成${NC}"
fi

# 設定 kubeconfig（標準做法）
if [ ! -f ~/.kube/config ]; then
    echo -e "${YELLOW}→ 設定 kubectl 配置...${NC}"
    mkdir -p ~/.kube
    $SUDO cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    $SUDO chown $USER:$USER ~/.kube/config
    chmod 600 ~/.kube/config
    echo -e "${GREEN}✓ kubectl 配置完成${NC}"
fi

# 設定環境變數（當前 session）
export KUBECONFIG=~/.kube/config

# ============================================
# 步驟 3: 檢查是否已安裝 Helm
# ============================================
echo ""
echo -e "${YELLOW}[3/7] 檢查 Helm...${NC}"
if command -v helm &> /dev/null; then
    echo -e "${GREEN}✓ Helm 已安裝${NC}"
else
    echo -e "${YELLOW}→ 安裝 Helm...${NC}"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo -e "${GREEN}✓ Helm 安裝完成${NC}"
fi

# ============================================
# 步驟 4: 輸入 Discord 設定
# ============================================
echo ""
echo -e "${YELLOW}[4/7] 設定 Discord Bot${NC}"
echo ""
echo "請準備以下資訊："
echo "1. Discord Bot Token (從 https://discord.com/developers/applications 取得)"
echo "2. Discord Channel ID (右鍵點擊頻道 → 複製 ID)"
echo ""

read -p "請輸入 Discord Bot Token: " DISCORD_BOT_TOKEN
read -p "請輸入 Discord Channel ID: " DISCORD_CHANNEL_ID

if [ -z "$DISCORD_BOT_TOKEN" ] || [ -z "$DISCORD_CHANNEL_ID" ]; then
    echo -e "${RED}✗ Token 或 Channel ID 不能為空！${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 設定已儲存${NC}"

# ============================================
# 步驟 5: 新增 Helm repo
# ============================================
echo ""
echo -e "${YELLOW}[5/7] 新增 OpenAB Helm repository...${NC}"
helm repo add openab https://openabdev.github.io/openab
helm repo update
echo -e "${GREEN}✓ Helm repo 已新增${NC}"

# ============================================
# 步驟 6: 安裝 OpenAB
# ============================================
echo ""
echo -e "${YELLOW}[6/7] 安裝 OpenAB...${NC}"
helm install openab openab/openab \
  --set agents.kiro.discord.botToken="$DISCORD_BOT_TOKEN" \
  --set-string "agents.kiro.discord.allowedChannels[0]=$DISCORD_CHANNEL_ID"

echo -e "${GREEN}✓ OpenAB 已安裝${NC}"

# ============================================
# 步驟 7: 等待 Pod 啟動
# ============================================
echo ""
echo -e "${YELLOW}[7/7] 等待 Pod 啟動...${NC}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=openab --timeout=300s 2>/dev/null || true
sleep 5

# ============================================
# 首次認證說明
# ============================================
echo ""
echo -e "${GREEN}=========================================="
echo "✓ 安裝完成！"
echo "==========================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  首次使用需要認證 kiro-cli：${NC}"
echo ""
echo "1. 執行以下指令進行 OAuth 登入："
echo -e "   ${GREEN}kubectl exec -it deployment/openab-kiro -- kiro-cli login --use-device-flow${NC}"
echo ""
echo "2. 按照提示在瀏覽器完成認證"
echo ""
echo "3. 認證完成後重啟 pod："
echo -e "   ${GREEN}kubectl rollout restart deployment/openab-kiro${NC}"
echo ""
echo -e "${YELLOW}📋 常用指令：${NC}"
echo "  查看 pod 狀態: kubectl get pods"
echo "  查看 logs:     kubectl logs -f deployment/openab-kiro"
echo "  刪除部署:      helm uninstall openab"
echo "  刪除 PVC:      kubectl delete pvc openab-kiro"
echo ""
echo -e "${GREEN}現在可以在 Discord 頻道 @mention 你的 bot 開始使用！${NC}"

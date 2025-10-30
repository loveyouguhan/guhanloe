#!/bin/bash

# ====================================
# Kiro2API 源码安全打包脚本 (Linux/Mac)
# ====================================
# 功能：打包源码到 deployment/kiro2api-source.tar.gz
# 特点：自动排除敏感文件和目录
# ====================================

set -e

echo "====================================="
echo "  Kiro2API 源码安全打包工具"
echo "====================================="
echo ""

# 检查是否在项目根目录
if [ ! -f "go.mod" ]; then
    echo "[错误] 请在项目根目录下运行此脚本！"
    exit 1
fi

# 设置变量
PROJECT_ROOT=$(pwd)
DEPLOYMENT_DIR="$PROJECT_ROOT/deployment"
TEMP_DIR="$DEPLOYMENT_DIR/temp_source"
TAR_FILE="$DEPLOYMENT_DIR/kiro2api-source.tar.gz"

# 创建临时目录
echo "[1/5] 创建临时目录..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# 定义要排除的模式
EXCLUDE_PATTERNS=(
    ".env"
    ".env.local"
    ".env.production"
    "auth_config.json"
    "*.log"
    ".git"
    ".gitignore"
    ".vscode"
    ".idea"
    "deployment/temp_*"
    "deployment/*.zip"
    "deployment/*.tar.gz"
    "deployment/kiro2api.tar"
    "node_modules"
    "vendor"
    "*.exe"
    "*.dll"
    "*.so"
    "*.dylib"
    "bin/"
    "dist/"
    "build/"
    "__pycache__"
    "*.pyc"
    ".DS_Store"
    "Thumbs.db"
    "*.swp"
    "*.swo"
    "*~"
)

# 构建 rsync 排除参数
echo "[2/5] 复制源码文件..."
echo "      排除敏感信息和临时文件..."

EXCLUDE_ARGS=""
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    EXCLUDE_ARGS="$EXCLUDE_ARGS --exclude=$pattern"
done

# 使用 rsync 复制文件
rsync -a $EXCLUDE_ARGS "$PROJECT_ROOT/" "$TEMP_DIR/" 2>/dev/null || {
    # 如果 rsync 不可用，使用 cp 和 find
    echo "      (使用 cp 命令，rsync 不可用)"
    cp -r "$PROJECT_ROOT/"* "$TEMP_DIR/" 2>/dev/null || true
    cp -r "$PROJECT_ROOT/".* "$TEMP_DIR/" 2>/dev/null || true
    
    # 手动删除排除的文件
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        find "$TEMP_DIR" -name "$pattern" -exec rm -rf {} + 2>/dev/null || true
    done
}

FILE_COUNT=$(find "$TEMP_DIR" -type f | wc -l)
echo "      ✓ 复制了约 $FILE_COUNT 个文件"

# 创建安全的示例文件
echo "[3/5] 创建示例配置文件..."

# 创建 .env.example
cat > "$TEMP_DIR/.env.example" << 'EOF'
# kiro2api 配置文件示例
# 复制此文件为 .env 并填入真实值

# ==================== Token配置 ====================
# 认证配置文件路径（JSON格式，包含refresh tokens）
KIRO_AUTH_TOKEN=./auth_config.json

# 客户端访问Token（用于API访问认证）
KIRO_CLIENT_TOKEN=your-secret-token-here

# ==================== 隐身模式配置 ====================
# 启用隐身模式（使用真实Kiro IDE请求头）
STEALTH_MODE=true

# 请求头策略（real_simulation=真实格式，random=随机生成）
HEADER_STRATEGY=real_simulation

# HTTP/2 模式（auto=自动，force=强制，disable=禁用）
STEALTH_HTTP2_MODE=auto

# ==================== 服务配置 ====================
# 服务端口
PORT=8080

# Gin 运行模式（release=生产，debug=调试，test=测试）
GIN_MODE=release

# ==================== 日志配置 ====================
# 日志级别（debug, info, warn, error）
LOG_LEVEL=info

# 日志格式（json, text）
LOG_FORMAT=json

# 控制台输出（true, false）
LOG_CONSOLE=true

# ==================== 工具配置 ====================
# Tool Description 最大长度（防止超长内容）
MAX_TOOL_DESCRIPTION_LENGTH=10000
EOF

echo "      ✓ 已创建 .env.example"

# 创建 auth_config.json.example（如果不存在）
if [ ! -f "$TEMP_DIR/auth_config.json.example" ]; then
    cat > "$TEMP_DIR/auth_config.json.example" << 'EOF'
[
  {
    "auth": "Social",
    "refreshToken": "your-social-refresh-token-here"
  },
  {
    "auth": "IdC",
    "refreshToken": "your-idc-refresh-token-here",
    "clientId": "your-client-id-here",
    "clientSecret": "your-client-secret-here"
  }
]
EOF
    echo "      ✓ 已创建 auth_config.json.example"
fi

# 创建 .gitignore（如果没有）
if [ ! -f "$TEMP_DIR/.gitignore" ]; then
    cat > "$TEMP_DIR/.gitignore" << 'EOF'
# 环境变量和敏感信息
.env
.env.local
.env.production
auth_config.json

# 日志文件
*.log

# IDE
.vscode
.idea

# 编译产物
bin/
dist/
build/
*.exe

# 依赖
vendor/
node_modules/

# 临时文件
*.tmp
*.swp
*.swo
*~
.DS_Store
Thumbs.db
EOF
    echo "      ✓ 已创建 .gitignore"
fi

# 压缩文件
echo "[4/5] 压缩源码包..."

rm -f "$TAR_FILE"
cd "$DEPLOYMENT_DIR"
tar -czf "kiro2api-source.tar.gz" -C "temp_source" .

TAR_SIZE=$(du -h "$TAR_FILE" | cut -f1)
echo "      ✓ 源码包大小: $TAR_SIZE"

# 清理临时目录
echo "[5/5] 清理临时文件..."
rm -rf "$TEMP_DIR"
echo "      ✓ 临时文件已清理"

echo ""
echo "====================================="
echo "  ✓ 源码打包完成！"
echo "====================================="
echo ""
echo "输出文件: $TAR_FILE"
echo "文件大小: $TAR_SIZE"
echo ""
echo "安全提示:"
echo "  ✓ 已排除 .env 文件（真实token）"
echo "  ✓ 已排除 auth_config.json 文件（真实配置）"
echo "  ✓ 已包含 .env.example 示例文件"
echo "  ✓ 已排除所有敏感信息"
echo ""

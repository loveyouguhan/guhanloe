#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================"
echo "   KIRO2API 一键部署脚本 (Linux/Mac)"
echo "========================================"
echo

# 检查是否以 root 运行（Docker 可能需要）
check_root() {
    if [ "$EUID" -ne 0 ] && ! groups | grep -q docker; then
        echo -e "${YELLOW}[警告] 当前用户不在 docker 组中，某些操作可能需要 sudo${NC}"
        echo "如需添加用户到 docker 组，请运行:"
        echo "  sudo usermod -aG docker \$USER"
        echo "  newgrp docker"
        echo
    fi
}

# 检查 Docker 是否安装
check_docker() {
    echo -e "${BLUE}[1/5] 检查 Docker 环境...${NC}"
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}[错误] 未检测到 Docker，请先安装 Docker${NC}"
        echo
        echo "安装方法:"
        echo "  Ubuntu/Debian: curl -fsSL https://get.docker.com | sh"
        echo "  CentOS/RHEL:   curl -fsSL https://get.docker.com | sh"
        echo "  Mac:           brew install docker"
        exit 1
    fi
    echo -e "${GREEN}[✓] Docker 已安装 ($(docker --version))${NC}"
    echo
}

# 检查 Docker Compose 是否安装
check_docker_compose() {
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}[错误] 未检测到 Docker Compose，请先安装${NC}"
        exit 1
    fi
    echo -e "${GREEN}[✓] Docker Compose 已安装${NC}"
    echo
}

# 检查配置文件
check_config() {
    echo -e "${BLUE}[2/5] 检查配置文件...${NC}"
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}[警告] 未找到 .env 配置文件${NC}"
        if [ -f ".env.example" ]; then
            echo "[提示] 正在复制 .env.example 为 .env..."
            cp .env.example .env
            echo
            echo "========================================"
            echo "   ⚠️  重要提示  ⚠️"
            echo "========================================"
            echo
            echo "已创建 .env 配置文件，请立即编辑此文件："
            echo
            echo "1. 修改 KIRO_AUTH_TOKEN（必须）"
            echo "   格式: [{\"auth\":\"Social\",\"refreshToken\":\"你的token\"}]"
            echo
            echo "2. 修改 KIRO_CLIENT_TOKEN（必须）"
            echo "   建议使用强密码，用于保护 API 访问"
            echo
            echo "3. 其他配置项可保持默认值"
            echo
            echo "========================================"
            echo
            
            # 尝试使用系统默认编辑器
            if command -v nano &> /dev/null; then
                read -p "按 Enter 打开 nano 编辑器，编辑完成后按 Ctrl+X 保存退出..."
                nano .env
            elif command -v vim &> /dev/null; then
                read -p "按 Enter 打开 vim 编辑器，编辑完成后按 :wq 保存退出..."
                vim .env
            elif command -v vi &> /dev/null; then
                read -p "按 Enter 打开 vi 编辑器，编辑完成后按 :wq 保存退出..."
                vi .env
            else
                echo "未找到文本编辑器，请手动编辑 .env 文件"
            fi
            
            echo
            read -p "配置完成后按 Enter 继续部署..."
        else
            echo -e "${RED}[错误] 未找到 .env.example 模板文件${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}[✓] 配置文件已存在${NC}"
    fi
    echo
}

# 检查镜像文件
check_image() {
    echo -e "${BLUE}[3/5] 检查 Docker 镜像...${NC}"
    if [ ! -f "kiro2api-image.tar" ]; then
        echo -e "${RED}[错误] 未找到 kiro2api-image.tar 镜像文件${NC}"
        echo "请确保 kiro2api-image.tar 与此脚本在同一目录"
        exit 1
    fi
    echo -e "${GREEN}[✓] 镜像文件存在${NC}"
    echo
}

# 导入 Docker 镜像
load_image() {
    echo -e "${BLUE}[4/5] 导入 Docker 镜像...${NC}"
    echo "这可能需要几分钟时间，请耐心等待..."
    if ! docker load -i kiro2api-image.tar; then
        echo -e "${RED}[错误] 镜像导入失败${NC}"
        exit 1
    fi
    echo -e "${GREEN}[✓] 镜像导入成功${NC}"
    echo
}

# 停止并删除旧容器
cleanup_old() {
    echo "检查并清理旧容器..."
    if docker ps -a | grep -q "kiro2api"; then
        echo "发现旧容器，正在停止并删除..."
        docker compose down
    fi
    echo
}

# 启动服务
start_service() {
    echo -e "${BLUE}[5/5] 启动 KIRO2API 服务...${NC}"
    if ! docker compose up -d; then
        echo -e "${RED}[错误] 服务启动失败${NC}"
        exit 1
    fi
    echo
    
    # 等待服务启动
    echo "等待服务启动..."
    sleep 3
    echo
    
    # 检查服务状态
    echo "检查服务状态..."
    if ! docker ps | grep -q "kiro2api"; then
        echo -e "${RED}[错误] 服务未正常运行${NC}"
        echo
        echo "查看日志:"
        docker compose logs
        exit 1
    fi
    echo
}

# 显示完成信息
show_completion() {
    echo "========================================"
    echo "   🎉 部署完成！"
    echo "========================================"
    echo
    echo "📊 Dashboard 地址: http://localhost:8080"
    echo "📚 API 文档: http://localhost:8080/v1/models"
    echo
    echo "💡 使用提示:"
    echo "1. Dashboard 可以查看 Token 状态和使用情况"
    echo "2. 在 Dashboard 的\"系统设置\"页面可以在线修改配置"
    echo "3. API 访问需要在请求头中添加:"
    echo "   Authorization: Bearer [你的KIRO_CLIENT_TOKEN]"
    echo
    echo "📝 常用命令:"
    echo "- 查看日志: docker compose logs -f"
    echo "- 停止服务: docker compose stop"
    echo "- 启动服务: docker compose start"
    echo "- 重启服务: docker compose restart"
    echo "- 完全卸载: docker compose down"
    echo
    echo "========================================"
    echo
}

# 主流程
main() {
    check_root
    check_docker
    check_docker_compose
    check_config
    check_image
    load_image
    cleanup_old
    start_service
    show_completion
}

# 运行主流程
main

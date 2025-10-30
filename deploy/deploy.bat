@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ========================================
echo    KIRO2API 一键部署脚本 (Windows)
echo ========================================
echo.

REM 检查 Docker 是否安装
echo [1/5] 检查 Docker 环境...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Docker，请先安装 Docker Desktop
    echo 下载地址: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo [✓] Docker 已安装
echo.

REM 检查配置文件
echo [2/5] 检查配置文件...
if not exist ".env" (
    echo [警告] 未找到 .env 配置文件
    if exist ".env.example" (
        echo [提示] 正在复制 .env.example 为 .env...
        copy .env.example .env >nul
        echo.
        echo ========================================
        echo   ⚠️  重要提示  ⚠️
        echo ========================================
        echo.
        echo 已创建 .env 配置文件，请立即编辑此文件：
        echo.
        echo 1. 修改 KIRO_AUTH_TOKEN（必须）
        echo    格式: [{"auth":"Social","refreshToken":"你的token"}]
        echo.
        echo 2. 修改 KIRO_CLIENT_TOKEN（必须）
        echo    建议使用强密码，用于保护 API 访问
        echo.
        echo 3. 其他配置项可保持默认值
        echo.
        echo ========================================
        echo.
        set /p continue="按 Enter 打开编辑器，编辑完成后保存并关闭..."
        notepad .env
        echo.
        set /p continue="配置完成后按 Enter 继续部署..."
    ) else (
        echo [错误] 未找到 .env.example 模板文件
        pause
        exit /b 1
    )
) else (
    echo [✓] 配置文件已存在
)
echo.

REM 检查镜像文件
echo [3/5] 检查 Docker 镜像...
if not exist "kiro2api-image.tar" (
    echo [错误] 未找到 kiro2api-image.tar 镜像文件
    echo 请确保 kiro2api-image.tar 与此脚本在同一目录
    pause
    exit /b 1
)
echo [✓] 镜像文件存在
echo.

REM 导入 Docker 镜像
echo [4/5] 导入 Docker 镜像...
echo 这可能需要几分钟时间，请耐心等待...
docker load -i kiro2api-image.tar
if %errorlevel% neq 0 (
    echo [错误] 镜像导入失败
    pause
    exit /b 1
)
echo [✓] 镜像导入成功
echo.

REM 停止并删除旧容器（如果存在）
echo 检查并清理旧容器...
docker ps -a | findstr "kiro2api" >nul 2>&1
if %errorlevel% equ 0 (
    echo 发现旧容器，正在停止并删除...
    docker compose down
)
echo.

REM 启动服务
echo [5/5] 启动 KIRO2API 服务...
docker compose up -d
if %errorlevel% neq 0 (
    echo [错误] 服务启动失败
    pause
    exit /b 1
)
echo.

REM 等待服务启动
echo 等待服务启动...
timeout /t 3 /nobreak >nul
echo.

REM 检查服务状态
echo 检查服务状态...
docker ps | findstr "kiro2api" >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 服务未正常运行
    echo.
    echo 查看日志:
    docker compose logs
    pause
    exit /b 1
)
echo.

echo ========================================
echo    🎉 部署完成！
echo ========================================
echo.
echo 📊 Dashboard 地址: http://localhost:8080
echo 📚 API 文档: http://localhost:8080/v1/models
echo.
echo 💡 使用提示:
echo 1. Dashboard 可以查看 Token 状态和使用情况
echo 2. 在 Dashboard 的"系统设置"页面可以在线修改配置
echo 3. API 访问需要在请求头中添加:
echo    Authorization: Bearer [你的KIRO_CLIENT_TOKEN]
echo.
echo 📝 常用命令:
echo - 查看日志: docker compose logs -f
echo - 停止服务: docker compose stop
echo - 启动服务: docker compose start
echo - 重启服务: docker compose restart
echo - 完全卸载: docker compose down
echo.
echo ========================================
echo.

REM 询问是否打开浏览器
set /p open="是否立即打开 Dashboard? (y/n): "
if /i "!open!"=="y" (
    start http://localhost:8080
)

pause

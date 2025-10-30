# KIRO2API 部署包文件清单

## 📦 文件列表

| 文件名 | 大小 | 说明 |
|--------|------|------|
| kiro2api-image.tar | ~23.4 MB | Docker 镜像文件 |
| docker-compose.yml | 1.7 KB | Docker Compose 配置 |
| .env.example | 2.8 KB | 环境变量配置示例 |
| deploy.bat | 4.1 KB | Windows 一键部署脚本 |
| deploy.sh | 6.3 KB | Linux/Mac 一键部署脚本 |
| README.md | 6.5 KB | 使用文档 |

## ✅ 文件完整性验证

所有文件已正确生成，可以打包分发！

## 📦 打包建议

### 方式一：ZIP 压缩包（推荐）

适合直接分发给用户：

```powershell
# Windows PowerShell
Compress-Archive -Path deploy\* -DestinationPath kiro2api-deploy.zip
```

```bash
# Linux/Mac
cd deploy
zip -r ../kiro2api-deploy.zip .
```

### 方式二：tar.gz 压缩包

适合 Linux 服务器：

```bash
tar -czf kiro2api-deploy.tar.gz -C deploy .
```

## 🚀 使用流程

用户拿到部署包后的使用步骤：

### Windows 用户
1. 解压 `kiro2api-deploy.zip`
2. 双击运行 `deploy.bat`
3. 按提示配置 `.env` 文件
4. 等待部署完成
5. 访问 http://localhost:8080

### Linux/Mac 用户
1. 解压部署包：
   ```bash
   unzip kiro2api-deploy.zip -d kiro2api
   cd kiro2api
   ```
   或
   ```bash
   tar -xzf kiro2api-deploy.tar.gz -C kiro2api
   cd kiro2api
   ```

2. 运行部署脚本：
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

3. 按提示配置 `.env` 文件
4. 等待部署完成
5. 访问 http://localhost:8080

## 📝 注意事项

1. **Docker 依赖**：用户需要提前安装 Docker 和 Docker Compose
2. **配置文件**：首次运行必须配置 `KIRO_AUTH_TOKEN` 和 `KIRO_CLIENT_TOKEN`
3. **端口占用**：默认使用 8080 端口，如被占用需修改配置
4. **网络要求**：首次启动需要从 AWS 刷新 Token（需要联网）

## 🔄 更新部署包

如果代码有更新，重新生成部署包：

1. 重新构建镜像：
   ```bash
   docker compose build
   ```

2. 导出新镜像：
   ```bash
   docker save -o deploy/kiro2api-image.tar kiro2api:local
   ```

3. 打包分发

## 💡 提示

- 部署包大小约 23-25 MB（压缩后约 10-12 MB）
- 适合内网或离线环境部署
- 包含完整的 Docker 镜像，无需联网拉取基础镜像

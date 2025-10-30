# Kiro2API 打包工具使用指南

## 📦 打包工具说明

本项目提供了安全的打包脚本，**自动排除所有敏感信息**（如真实的 `.env` 和 `auth_config.json`）。

---

## 🔐 安全特性

所有打包脚本都会自动排除：
- ✅ `.env` 文件（包含真实 token）
- ✅ `auth_config.json` 文件（真实认证配置）
- ✅ `.git` 目录（版本历史）
- ✅ 日志文件
- ✅ IDE 配置文件
- ✅ 编译产物和临时文件

同时会自动包含：
- ✅ `.env.example`（示例配置）
- ✅ `auth_config.json.example`（示例配置）
- ✅ `.gitignore`（忽略规则）

---

## 📋 打包脚本列表

### 1️⃣ `package_source.ps1` / `package_source.sh`
**功能**：仅打包源码（不含镜像）

**输出**：`deployment/kiro2api-source.zip` 或 `deployment/kiro2api-source.tar.gz`

**使用场景**：
- 需要从源码编译
- 需要自定义修改代码
- 想要最小的文件大小

**Windows 使用**：
```powershell
cd E:\kiro2api
.\deployment\package_source.ps1
```

**Linux/Mac 使用**：
```bash
cd /path/to/kiro2api
chmod +x deployment/package_source.sh
./deployment/package_source.sh
```

---

### 2️⃣ `package_all.ps1`
**功能**：打包完整部署包（镜像 + 源码 + 部署脚本）

**输出**：`kiro2api-deploy-YYYYMMDD_HHMMSS.zip`

**包含内容**：
- Docker 镜像文件 (`kiro2api.tar`)
- 源码压缩包 (`kiro2api-source.zip`)
- 部署脚本 (`deploy.ps1` / `deploy.sh`)
- Docker Compose 配置
- 环境变量示例
- 部署说明文档

**使用场景**：
- 发布给用户使用
- 完整的可移植部署包
- 包含所有必需文件

**Windows 使用**：
```powershell
cd E:\kiro2api

# 确保 Docker 镜像已构建
docker compose build

# 执行完整打包
.\deployment\package_all.ps1
```

**Linux/Mac 使用**：
```bash
cd /path/to/kiro2api

# 确保 Docker 镜像已构建
docker compose build

# 执行打包（需要先创建对应的 shell 脚本）
./deployment/package_all.sh
```

---

## 🎯 推荐使用方式

### 场景 1：发布生产版本
```powershell
# 1. 确保代码最新且已测试
# 2. 构建镜像
docker compose build

# 3. 导出镜像（如果还没有）
docker save -o deployment/kiro2api.tar kiro2api:latest

# 4. 打包源码（安全）
.\deployment\package_source.ps1

# 5. 创建完整部署包
.\deployment\package_all.ps1

# 6. 输出文件：kiro2api-deploy-YYYYMMDD_HHMMSS.zip
```

### 场景 2：仅分享源码
```powershell
# 直接打包源码
.\deployment\package_source.ps1

# 输出文件：deployment/kiro2api-source.zip
```

---

## 🔍 打包后检查清单

打包完成后，建议检查：

1. **解压测试**：解压打包文件，确认没有敏感信息
   ```powershell
   # 创建测试目录
   mkdir test_unpack
   cd test_unpack
   
   # 解压
   Expand-Archive ..\kiro2api-deploy-*.zip -DestinationPath .
   
   # 检查是否存在敏感文件（应该不存在）
   Get-ChildItem -Recurse -Force | Where-Object { $_.Name -eq ".env" -or $_.Name -eq "auth_config.json" }
   
   # 检查是否存在示例文件（应该存在）
   Get-ChildItem -Recurse -Force | Where-Object { $_.Name -eq ".env.example" -or $_.Name -eq "auth_config.json.example" }
   ```

2. **文件大小检查**：
   - 源码包：约 1-5 MB（不含镜像）
   - 镜像文件：约 20-50 MB
   - 完整部署包：约 25-60 MB

3. **部署测试**：
   ```powershell
   # 在另一台干净的机器上测试部署
   cd test_unpack
   
   # Windows
   .\deploy.ps1
   
   # Linux
   chmod +x deploy.sh
   ./deploy.sh
   ```

---

## ⚠️ 安全注意事项

### ❌ 绝不应该出现在打包文件中
- 真实的 `.env` 文件
- 真实的 `auth_config.json` 文件
- 包含真实 token 的任何文件
- `.git` 目录（可能包含历史中的敏感信息）

### ✅ 应该包含在打包文件中
- `.env.example`（所有值都是占位符）
- `auth_config.json.example`（所有值都是占位符）
- 源代码
- Dockerfile 和 docker-compose.yml
- 部署脚本和文档

---

## 🛠️ 常见问题

### Q1: 打包后文件太大？
A: 检查是否包含了不必要的文件。可以编辑脚本中的 `excludePatterns` 添加更多排除规则。

### Q2: 如何验证没有泄露敏感信息？
A: 解压打包文件后，全局搜索你的真实 token 或邮箱地址，确保没有匹配结果。

### Q3: 打包失败？
A: 
- 确保在项目根目录运行脚本
- 检查 `deployment` 目录是否存在
- 确保有足够的磁盘空间
- Windows: 以管理员权限运行 PowerShell

### Q4: Linux 脚本无法执行？
A:
```bash
# 添加执行权限
chmod +x deployment/package_source.sh
chmod +x deployment/deploy.sh

# 然后执行
./deployment/package_source.sh
```

---

## 📝 自定义排除规则

如果需要排除更多文件，编辑脚本中的 `excludePatterns` 数组：

```powershell
$excludePatterns = @(
    ".env",
    "auth_config.json",
    "your_custom_file.txt",     # 添加自定义排除
    "sensitive_folder/",        # 添加文件夹排除
    # ...
)
```

---

## 📞 技术支持

如有问题，请检查：
1. 打包日志输出
2. 是否按顺序执行步骤
3. Docker 是否正常运行
4. 磁盘空间是否充足

---

**最后提醒**：打包前务必检查 `.env` 和 `auth_config.json` 是否已被排除！

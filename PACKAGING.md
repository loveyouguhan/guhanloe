# 🎁 Kiro2API 打包与分发指南

## 📦 快速开始

### Windows 用户

```powershell
# 在项目根目录运行

# 方式1: 仅打包源码（最小体积，约 50MB）
.\deployment\package_source.ps1

# 方式2: 打包完整部署包（镜像+源码+脚本，约 100MB）
.\deployment\package_all.ps1
```

### Linux/Mac 用户

```bash
# 在项目根目录运行

# 方式1: 仅打包源码
chmod +x deployment/package_source.sh
./deployment/package_source.sh

# 方式2: 完整部署包（需要自己创建对应脚本）
# 参考 package_all.ps1 创建 package_all.sh
```

---

## 🎯 打包方式对比

| 打包方式 | 输出文件 | 大小 | 适用场景 |
|---------|---------|------|---------|
| **源码打包** | `deployment/kiro2api-source.zip` | ~50MB | 开发者使用，需要自己编译 |
| **完整部署包** | `kiro2api-deploy-YYYYMMDD_HHMMSS.zip` | ~100MB | 终端用户，开箱即用 |

---

## 🔐 安全保证

所有打包脚本都会**自动排除**以下敏感信息：

### ❌ 不会打包（敏感信息）
- ✅ `.env` - 真实环境变量和 token
- ✅ `auth_config.json` - 真实认证配置
- ✅ `.git` - 版本历史记录
- ✅ `*.log` - 日志文件
- ✅ IDE 配置文件 (`.vscode`, `.idea`)

### ✅ 会打包（示例文件）
- ✅ `.env.example` - 配置示例
- ✅ `auth_config.json.example` - 认证配置示例
- ✅ 所有源代码文件
- ✅ Dockerfile 和 docker-compose.yml
- ✅ 部署脚本和文档

---

## 📝 详细使用步骤

### 方案 1: 打包源码（用于开发）

适用于：
- 需要查看或修改源代码
- 从源码编译
- 最小体积传输

**步骤：**

```powershell
# 1. 进入项目目录
cd E:\kiro2api

# 2. 运行打包脚本
.\deployment\package_source.ps1

# 3. 获取输出文件
# 输出位置: deployment\kiro2api-source.zip
```

**输出内容：**
- ✅ 完整源代码
- ✅ `.env.example`（配置示例）
- ✅ `auth_config.json.example`（认证示例）
- ✅ Dockerfile 和构建脚本
- ❌ 不含 Docker 镜像（需要自己构建）

---

### 方案 2: 打包完整部署包（推荐用于分发）

适用于：
- 发布给终端用户
- 快速部署，开箱即用
- 包含所有必需文件

**步骤：**

```powershell
# 1. 进入项目目录
cd E:\kiro2api

# 2. 确保 Docker 镜像已构建
docker compose build

# 3. 运行完整打包脚本
.\deployment\package_all.ps1

# 4. 获取输出文件
# 输出位置: kiro2api-deploy-YYYYMMDD_HHMMSS.zip
```

**输出内容：**
- ✅ Docker 镜像文件 (`kiro2api.tar`)
- ✅ 源码压缩包 (`kiro2api-source.zip`)
- ✅ 部署脚本 (`deploy.ps1` / `deploy.sh`)
- ✅ Docker Compose 配置
- ✅ 环境变量示例 (`.env.example`)
- ✅ 完整文档 (`README.md`)

---

## 🧪 安全验证步骤

打包完成后，**强烈建议**执行以下验证：

### 步骤 1: 解压验证

```powershell
# 创建测试目录
mkdir test_package
cd test_package

# 解压打包文件
Expand-Archive ..\kiro2api-deploy-*.zip

# 或解压源码包
Expand-Archive ..\deployment\kiro2api-source.zip
```

### 步骤 2: 检查敏感文件（应该不存在）

```powershell
# 搜索敏感文件
Get-ChildItem -Recurse -Force | Where-Object { 
    $_.Name -eq ".env" -or 
    $_.Name -eq "auth_config.json" 
}

# 应该返回空结果！
# 如果找到文件，说明打包脚本有问题！
```

### 步骤 3: 检查示例文件（应该存在）

```powershell
# 搜索示例文件
Get-ChildItem -Recurse -Force | Where-Object { 
    $_.Name -eq ".env.example" -or 
    $_.Name -eq "auth_config.json.example" 
}

# 应该找到这些文件
```

### 步骤 4: 搜索真实 Token（应该不存在）

```powershell
# 在所有文件中搜索你的真实 token
# 替换 "your-real-token" 为你的实际 token
Get-ChildItem -Recurse -File | Select-String "your-real-token"

# 应该返回空结果！
# 如果找到，说明 token 泄露了！
```

### 步骤 5: 测试部署

```powershell
# 在测试目录中尝试部署
cd test_package\kiro2api-deploy-*

# 运行部署脚本（会提示你配置 .env）
.\deploy.ps1
```

---

## 📂 文件结构说明

### 打包后的完整部署包结构

```
kiro2api-deploy-20251030_123456.zip
├── kiro2api.tar                  # Docker 镜像（~40MB）
├── kiro2api-source.zip           # 源码包（~50MB）
├── docker-compose.yml            # Docker Compose 配置
├── .env.example                  # 环境变量示例
├── README.md                     # 部署说明
├── deploy.ps1                    # Windows 部署脚本
└── deploy.sh                     # Linux 部署脚本
```

### 源码包内部结构

```
kiro2api-source.zip
├── .env.example                  # 配置示例（非真实配置）
├── auth_config.json.example      # 认证示例（非真实配置）
├── go.mod                        # Go 依赖
├── Dockerfile                    # 镜像构建文件
├── docker-compose.yml            # 容器编排
├── README.md                     # 项目说明
├── cmd/                          # 主程序
├── internal/                     # 内部包
├── static/                       # 静态资源
└── ...                           # 其他源代码
```

---

## ⚠️ 重要安全提示

### 🚨 打包前必查清单

- [ ] 确认 `.env` 文件不在 Git 跟踪中
- [ ] 确认 `auth_config.json` 不在 Git 跟踪中
- [ ] 检查是否有其他包含敏感信息的文件
- [ ] 运行打包脚本
- [ ] 解压验证是否包含敏感信息
- [ ] 搜索真实 token 确认未泄露

### 🛡️ 如果发现敏感信息泄露

1. **立即停止分发**已打包的文件
2. **更换所有泄露的 token** 和密钥
3. **检查打包脚本**的排除规则
4. **重新打包**并验证

---

## 🔧 自定义排除规则

如果需要排除更多文件，编辑 `package_source.ps1`：

```powershell
$exclude = @(
    ".env", 
    ".env.*", 
    "auth_config.json", 
    "*.log",
    # 添加你的自定义排除规则
    "my_secret_file.txt",
    "private_folder",
)
```

---

## 📞 常见问题

### Q: 打包后文件太大？
**A:** 检查是否包含了不必要的大文件（如编译产物、node_modules）。可以在排除列表中添加。

### Q: 如何验证没有泄露敏感信息？
**A:** 按照上面的"安全验证步骤"执行，特别是搜索真实 token 的步骤。

### Q: 能否在 CI/CD 中自动打包？
**A:** 可以！在 GitHub Actions 或其他 CI 中调用打包脚本即可。

### Q: 打包失败怎么办？
**A:** 检查：
1. 是否在项目根目录运行
2. 是否有足够的磁盘空间
3. Windows: 是否以管理员权限运行
4. Docker: 镜像是否已构建

---

## 📦 推荐工作流程

### 发布新版本

```powershell
# 1. 更新代码和版本号
git commit -am "Release v1.0.0"
git tag v1.0.0

# 2. 构建 Docker 镜像
docker compose build

# 3. 测试容器
docker compose up -d
# 访问 http://localhost:8080 测试功能

# 4. 停止测试容器
docker compose down

# 5. 打包完整部署包
.\deployment\package_all.ps1

# 6. 验证打包文件
mkdir test_release
cd test_release
Expand-Archive ..\kiro2api-deploy-*.zip

# 7. 检查安全性
Get-ChildItem -Recurse | Where-Object { $_.Name -eq ".env" }
# 应该返回空！

# 8. 分发打包文件
# 上传到 GitHub Release 或其他平台
```

---

## 📄 相关文档

- [部署说明](deployment/README.md) - 用户部署指南
- [打包详细指南](deployment/PACKAGING_GUIDE.md) - 打包工具详细说明
- [项目 README](README.md) - 项目总体说明

---

**最后提醒**：分发前务必验证没有泄露敏感信息！🔐

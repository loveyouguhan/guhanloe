# KIRO2API 部署包

这是 KIRO2API 的一键部署包，包含了所有必要的文件和脚本，让你可以快速部署服务。

## 📦 包含文件

```
deploy/
├── kiro2api-image.tar      # Docker 镜像文件
├── docker-compose.yml      # Docker Compose 配置
├── .env.example            # 环境变量配置示例
├── deploy.bat              # Windows 一键部署脚本
├── deploy.sh               # Linux/Mac 一键部署脚本
└── README.md               # 本文档
```

## 🚀 快速开始

### Windows 用户

1. **双击运行** `deploy.bat` 脚本
2. 按照提示配置 `.env` 文件
3. 等待部署完成
4. 访问 http://localhost:8080

### Linux/Mac 用户

1. 给脚本添加执行权限：
   ```bash
   chmod +x deploy.sh
   ```

2. 运行部署脚本：
   ```bash
   ./deploy.sh
   ```

3. 按照提示配置 `.env` 文件
4. 等待部署完成
5. 访问 http://localhost:8080

## ⚙️ 配置说明

首次运行部署脚本时，会自动创建 `.env` 配置文件。你需要修改以下**必填项**：

### 1. KIRO_AUTH_TOKEN（必须配置）

这是你的 AWS CodeWhisperer 认证信息，支持两种格式：

#### 方式一：Social 认证（推荐，简单）

```json
[{"auth":"Social","refreshToken":"你的refresh_token"}]
```

#### 方式二：IdC 认证（企业用户）

```json
[{"auth":"IdC","refreshToken":"你的refresh_token","clientId":"你的client_id","clientSecret":"你的client_secret"}]
```

#### 方式三：多账号池（支持混合认证）

```json
[
  {"auth":"Social","refreshToken":"token1"},
  {"auth":"IdC","refreshToken":"token2","clientId":"id2","clientSecret":"secret2"},
  {"auth":"Social","refreshToken":"token3"}
]
```

> 💡 如何获取这些信息？请参考项目主仓库的文档。

### 2. KIRO_CLIENT_TOKEN（必须配置）

这是用于保护你的 API 不被未授权访问的密码，建议使用强密码：

```env
KIRO_CLIENT_TOKEN=你的强密码123456
```

### 3. 其他配置（可选）

其他配置项都有默认值，一般情况下保持默认即可：

- `PORT=8080` - 服务端口
- `GIN_MODE=release` - 运行模式
- `LOG_LEVEL=info` - 日志级别
- `STEALTH_MODE=true` - 隐身模式
- 等等...

详细说明请查看 `.env.example` 文件中的注释。

## 📊 使用 Dashboard

部署完成后，访问 http://localhost:8080 可以打开 Dashboard，功能包括：

### Token 管理
- 实时查看所有 Token 的状态
- 查看剩余次数和过期时间
- 启用/禁用特定 Token
- 删除不需要的 Token
- 添加新的 Token（无需重启）

### 系统设置
- 在线修改配置（大部分配置立即生效，无需重启）
- 查看和修改 KIRO_CLIENT_TOKEN
- 调整隐身模式设置
- 修改日志级别等

## 🔌 API 使用

### 兼容 OpenAI 格式

KIRO2API 完全兼容 OpenAI API 格式，只需修改两个地方：

1. **API Base URL**: `http://localhost:8080/v1`
2. **API Key**: 使用你配置的 `KIRO_CLIENT_TOKEN`

### 示例代码

#### Python (OpenAI SDK)

```python
from openai import OpenAI

client = OpenAI(
    api_key="你的KIRO_CLIENT_TOKEN",
    base_url="http://localhost:8080/v1"
)

response = client.chat.completions.create(
    model="anthropic.claude-sonnet-4-0",
    messages=[
        {"role": "user", "content": "Hello!"}
    ]
)

print(response.choices[0].message.content)
```

#### cURL

```bash
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 你的KIRO_CLIENT_TOKEN" \
  -d '{
    "model": "anthropic.claude-sonnet-4-0",
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

### 兼容 Anthropic 格式

也支持原生 Anthropic Messages API 格式：

```bash
curl http://localhost:8080/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: 你的KIRO_CLIENT_TOKEN" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-0",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

## 🛠️ 常用命令

### 查看日志
```bash
docker compose logs -f
```

### 停止服务
```bash
docker compose stop
```

### 启动服务
```bash
docker compose start
```

### 重启服务
```bash
docker compose restart
```

### 完全卸载
```bash
docker compose down
```

### 卸载并删除数据
```bash
docker compose down -v
```

## 🔧 故障排除

### 1. 端口被占用

如果 8080 端口已被占用，修改 `.env` 文件中的 `PORT` 配置：

```env
PORT=8081
```

然后重启服务：
```bash
docker compose down
docker compose up -d
```

### 2. Token 刷新失败

- 检查 `KIRO_AUTH_TOKEN` 配置是否正确
- 查看日志了解具体错误：`docker compose logs -f`
- 在 Dashboard 中查看 Token 状态

### 3. 无法访问 Dashboard

- 检查 Docker 容器是否正常运行：`docker ps`
- 检查防火墙是否开放了 8080 端口
- 尝试使用 `http://127.0.0.1:8080` 而不是 `localhost`

### 4. API 返回 401 未授权

- 检查请求头中的 `Authorization: Bearer [token]` 是否正确
- 确认使用的是 `.env` 中配置的 `KIRO_CLIENT_TOKEN`
- 可以在 Dashboard 的"系统设置"中查看当前的 CLIENT_TOKEN

## 📝 更新部署

如果需要更新到新版本：

1. 停止当前服务：`docker compose down`
2. 备份当前的 `.env` 文件
3. 解压新的部署包到同一目录（覆盖旧文件）
4. 恢复 `.env` 文件
5. 重新运行部署脚本

## 🔒 安全建议

1. **修改默认密码**：务必修改 `KIRO_CLIENT_TOKEN` 为强密码
2. **不要暴露到公网**：默认配置仅监听本地，如需外网访问请配置反向代理和 HTTPS
3. **定期更新**：关注项目更新，及时升级到最新版本
4. **保护配置文件**：`.env` 文件包含敏感信息，不要泄露

## 📚 更多资源

- 项目主页：[GitHub](https://github.com/your-repo/kiro2api)
- 问题反馈：[Issues](https://github.com/your-repo/kiro2api/issues)
- 更新日志：[CHANGELOG.md](https://github.com/your-repo/kiro2api/blob/main/CHANGELOG.md)

## 📄 许可证

本项目采用 MIT 许可证，详见 LICENSE 文件。

---

💡 **提示**：遇到问题？先查看日志 `docker compose logs -f`，大部分问题都能从日志中找到原因！

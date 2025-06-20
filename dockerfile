# 使用官方 Bun 镜像作为基础镜像
FROM oven/bun:1-alpine AS base

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY package.json bun.lock ./

# 安装依赖（利用 Docker 层缓存）
RUN bun install --frozen-lockfile --production

# 复制源代码和配置文件
COPY src ./src
COPY .env ./
COPY tsconfig.json ./

# 暴露应用端口
EXPOSE 8000

# 设置环境变量
ENV NODE_ENV=production

# 创建非 root 用户来运行应用
RUN addgroup -g 1001 -S bunuser && \
    adduser -S bunuser -u 1001

# 更改目录所有权
RUN chown -R bunuser:bunuser /app
USER bunuser

# 启动应用
CMD ["bun", "run", "src/index.ts"]

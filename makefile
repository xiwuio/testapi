# 定义变量
DOCKER_IMAGE_NAME := testapi
DOCKER_IMAGE_TAG := latest
DOCKER_IMAGE := $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
REMOTE_HOST := txy-sgp-2c4g
DOCKER_BUILD_PLATFORM := linux/amd64
PROJECT_PORT := 8000
PROJECT_PATH := $(HOME)/$(DOCKER_IMAGE_NAME)

# 构建前端项目
.PHONY: frontend
frontend:
	cd svelte && pnpm run build && cd ..

# 构建 Docker 镜像
.PHONY: build
build:
	docker rmi $(DOCKER_IMAGE) || true
	docker build --platform $(DOCKER_BUILD_PLATFORM) -t $(DOCKER_IMAGE) .
	docker image prune -f

# 保存并传输镜像
.PHONY: save
save:
	docker save $(DOCKER_IMAGE) | gzip | ssh $(REMOTE_HOST) "docker load"

# 在本地运行容器
.PHONY: run
run:
	docker ps -a | grep $(DOCKER_IMAGE_NAME) || true && \
	docker rm -f $(DOCKER_IMAGE_NAME) || true && \
	docker image prune -f && \
	docker run -itd --name $(DOCKER_IMAGE_NAME) -p $(PROJECT_PORT):$(PROJECT_PORT) $(DOCKER_IMAGE) && \
	docker ps | grep $(DOCKER_IMAGE_NAME)

# 在远程主机上运行容器
.PHONY: remote-run
remote-run:
	ssh $(REMOTE_HOST) "\
	docker ps -a | grep $(DOCKER_IMAGE_NAME) || true && \
	docker rm -f $(DOCKER_IMAGE_NAME) || true && \
	docker image prune -f && \
	docker run -itd --name $(DOCKER_IMAGE_NAME) -p $(PROJECT_PORT):$(PROJECT_PORT) $(DOCKER_IMAGE) && \
	docker ps | grep $(DOCKER_IMAGE_NAME)"

# 在远程主机上创建目录
.PHONY: remote-mkdir
remote-mkdir:
	ssh $(REMOTE_HOST) "mkdir -p $(PROJECT_PATH)/logs"

# 清理本地镜像
.PHONY: clean
clean:
	docker rmi $(DOCKER_IMAGE) || true && docker image prune -f

# 查看远程主机上的 Docker 状态
.PHONY: remote-ps
remote-ps:
	ssh $(REMOTE_HOST) "docker ps -a"

# 查看远程主机上的镜像
.PHONY: remote-images
remote-images:
	ssh $(REMOTE_HOST) "docker images"

# 部署流程
.PHONY: deploy
deploy:
	make build
	make save
	make remote-run
	make clean

# 生成随机密码(只包含字母和数字的 32 位字符串)
.PHONY: genpwd
genpwd:
	openssl rand -base64 24 | tr -dc A-Za-z0-9 | head -c 32

# 帮助信息
.PHONY: help
help:
	@echo "可用的命令:"
	@echo "  make pg               - 启动本地的 postgres 数据库"
	@echo "  make rs               - 启动本地的 redis 数据库"
	@echo "  make frontend         - 构建前端项目"
	@echo "  make build            - 构建 Docker 镜像"
	@echo "  make save             - 保存并传输镜像到远程主机"
	@echo "  make remote-run       - 在远程主机上运行容器"
	@echo "  make remote-ps        - 查看远程主机上的 Docker 状态"
	@echo "  make remote-mkdir     - 在远程主机上创建目录"
	@echo "  make remote-images    - 查看远程主机上的镜像"
	@echo "  make deploy           - 执行完整的部署流程"
	@echo "  make clean            - 清理本地镜像"
	@echo "  make genpwd           - 生成随机密码"
	@echo "  make help             - 显示此帮助信息"

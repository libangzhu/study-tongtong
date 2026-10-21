#!/usr/bin/env bash
# 把三年级数学演示页构建成容器并启动。
# 用法: ./deploy.sh [up|down|restart|status|logs|health]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

PORT="${PORT:-8080}"
export PORT

usage() {
  cat <<'EOF'
用法: ./deploy.sh <命令>

命令:
  up        构建镜像并在后台启动（默认）
  down      停止并删除容器
  restart   重启容器
  status    查看容器状态
  logs      跟踪容器日志
  health    请求本机健康检查

环境变量:
  PORT      宿主机端口，默认 8080

示例:
  ./deploy.sh
  PORT=9090 ./deploy.sh up
  ./deploy.sh logs
EOF
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "未找到 docker。请先安装 Docker 后再部署。" >&2
    exit 1
  fi
  if ! docker info >/dev/null 2>&1; then
    echo "Docker 未运行，或当前用户没有权限访问 Docker。" >&2
    exit 1
  fi
}

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    echo "未找到 Docker Compose。请安装 Docker Compose v2 后重试。" >&2
    exit 1
  fi
}

wait_healthy() {
  local url="http://127.0.0.1:${PORT}/healthz"
  if ! command -v curl >/dev/null 2>&1; then
    echo "未找到 curl，已跳过本机健康检查。"
    echo "请在浏览器打开 http://127.0.0.1:${PORT}/"
    return 0
  fi
  local i
  for i in $(seq 1 30); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo "健康检查通过: $url"
      echo "演示页面: http://127.0.0.1:${PORT}/"
      return 0
    fi
    sleep 1
  done
  echo "容器已创建，但 ${url} 在 30 秒内没有返回成功。" >&2
  compose logs --tail=50 >&2 || true
  exit 1
}

cmd_up() {
  require_docker
  compose up -d --build
  wait_healthy
}

cmd_down() {
  require_docker
  compose down
  echo "已停止并删除容器。"
}

cmd_restart() {
  require_docker
  compose restart
  wait_healthy
}

cmd_status() {
  require_docker
  compose ps
}

cmd_logs() {
  require_docker
  compose logs -f --tail=100
}

cmd_health() {
  local url="http://127.0.0.1:${PORT}/healthz"
  if ! command -v curl >/dev/null 2>&1; then
    echo "未找到 curl，无法在本机请求 ${url}。" >&2
    exit 1
  fi
  curl -fsS "$url"
  echo
}

ACTION="${1:-up}"
case "$ACTION" in
  up) cmd_up ;;
  down) cmd_down ;;
  restart) cmd_restart ;;
  status) cmd_status ;;
  logs) cmd_logs ;;
  health) cmd_health ;;
  -h|--help|help) usage ;;
  *)
    echo "未知命令: $ACTION" >&2
    usage >&2
    exit 1
    ;;
esac

#!/bin/sh

# 确保命令返回非零状态，脚本会自动退出
set -e

echo "run db migration"
cat /app/app.env
source /app/app.env
/app/migrate -path /app/migration -database "$DB_SOURCE" -verbose up

echo "start the app"
exec "$@" # 获取传递给脚本的所有参数并运行它
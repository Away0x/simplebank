# Build stage
FROM golang:1.17-alpine3.13 AS builder
WORKDIR /app
COPY . .
RUN go build -o main main.go
RUN apk --no-cache add curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.14.1/migrate.linux-amd64.tar.gz | tar xvz

# Run stage
FROM alpine:3.13
WORKDIR /app
# copy 名为 builder 的 stage 里面的文件
COPY --from=builder /app/main .
COPY --from=builder /app/migrate.linux-amd64 ./migrate
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
COPY db/migration ./migration

EXPOSE 8080
# 当 CMD 单独使用时，其作为命令执行
# 当 CMD 与 ENTRYPOINT 配合使用时，CMD 会作为参数传递给 ENTRYPOINT
#    等于 ENTRYPOINT [ "/app/start.sh", "/app/main" ]
#    不过将 CMD 与 ENTRYPOINT 分开更灵活，方便以后替换 (方便运行时随时指定其他命令)
CMD [ "/app/main" ]
ENTRYPOINT [ "/app/start.sh" ]
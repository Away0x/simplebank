# 学习 [Backend master class [Golang, Postgres, Docker]](https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE) 课程的相关代码
> [techschool]https://github.com/techschool/simplebank

# 初始化项目
```bash
# install
brew install golang-migrate
brew install sqlc
brew install protobuf
go install github.com/rakyll/statik # Embed files into a Go executable
go install github.com/golang/mock/mockgen@v1.6.0
# setup
make network
make postgres
make createdb
make migrateup
make test
make server

# docker-compose
docker compose up
```

## Docker
```bash
docker pull registry.cn-hangzhou.aliyuncs.com/away0x/simplebank:3551c6e31fa2d8e718940cb0f935ce6feac915c6
docker run -p 8080:8080 registry.cn-hangzhou.aliyuncs.com/away0x/simplebank:3551c6e31fa2d8e718940cb0f935ce6feac915c6
```

## Postgres
> [Image](https://hub.docker.com/_/postgres)

```bash
# pull image
docker pull postgres:12-alpine

# create container(容器名 postgres12)
docker run --name postgres12 -p 5432:5432 \
    -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret \
    -d postgres:12-alpine

# 查看容器日志
docker logs postgres12

# 启动/停止
docker start/stop postgres12
```
```bash
# 进入 postgres (该容器默认在本地设置了信任身份验证，所以 localhost 连接时不需要密码)
docker exec -it postgres12 psql -U root
docker exec -it postgres12 psql -U root -d demodb # 指定数据库
# shell
docker exec -it postgres12 /bin/sh


# 容器提供了一些命令方便 shell 与 postgres 交互,
#  - 创建数据库: createdb
#  - 删除数据库: dropdb
docker exec -it postgres12 createdb --username=root --owner=root demodb
docker exec -it postgres12 psql -U root demodb # 进入数据库
docker exec -it postgres12 dropdb demodb
```

## Migration
> [migrate](https://github.com/golang-migrate/migrate)

```bash
brew install golang-migrate
```
```bash
# 创建迁移
migrate create -ext sql -dir db/migration -seq init_schema

# 运行迁移
migrate -path db/migration \
    -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" \
    -verbose \ # 打印日志
    up
```

## SQLC
> [sqlc](https://github.com/kyleconroy/sqlc)


## gomock
> [gomock](https://github.com/golang/mock)

```bash
go install github.com/golang/mock/mockgen@v1.6.0

# 对 simplebank/db/sqlc 下的 Store interface 生成 mock 文件到 db/mock/store.go 文件中，并指定包名为 mockdb
mockgen -package=mockdb -destination=db/mock/store.go simplebank/db/sqlc Store
```

```go
// 使用 gomock 进行测试的例子
func TestGetAccountAPI(t *testing.T) {
	account := randomAccount()

	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	store := mockdb.NewMockStore(ctrl)

	// build stubs
	// 期望 store 的 GetAccount 在请求接口中被调用一次，检测其被调用时接收的参数和 mock 返回值
	// 如果接口逻辑中没有调用 store 的 GetAccount 方法，则测试会报错
	store.EXPECT().
		GetAccount(gomock.Any(), gomock.Eq(account.ID)).
		Times(1).
		Return(account, nil)

	// 测试 /accounts/:id 接口
	server, _ := NewServer(util.Config{}, store)
	recorder := httptest.NewRecorder()

	url := fmt.Sprintf("/accounts/%d", account.ID)
	request := httptest.NewRequest(http.MethodGet, url, nil)

	server.router.ServeHTTP(recorder, request)

	// check response
	require.Equal(t, http.StatusOK, recorder.Code)
	requireBodyMatchAccount(t, recorder.Body, account)
}

func requireBodyMatchAccount(t *testing.T, body *bytes.Buffer, account db.Account) {
	data, err := ioutil.ReadAll(body)
	require.NoError(t, err)

	var gotAccount db.Account
	err = json.Unmarshal(data, &gotAccount)
	require.NoError(t, err)
	require.Equal(t, account, gotAccount)
}
```

## DBML
> https://dbdocs.io/

```bash
npm install -g dbdocs
npm install -g @dbml/cli
dbml2sql --version
```

## GRPC
```bash
brew install protobuf
protoc --version
go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
protoc-gen-go --version
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
protoc-gen-go-grpc --version
```
```bash
# grpc client
# https://github.com/ktr0731/evans
brew tap ktr0731/evans
brew install evans

# e.g.
show service
call CreateUser
```

### gRPC Gateway (grpc -> http)
> https://github.com/grpc-ecosystem/grpc-gateway




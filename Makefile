DB_URL=postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable

network:
	docker network create bank-network

# Start postgres container
postgres:
	docker run --name postgres12 --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine

# Start mysql container
mysql:
	docker run --name mysql8 -p 3306:3306  -e MYSQL_ROOT_PASSWORD=secret -d mysql:8

# Create simple_bank database:
createdb:
	docker exec -it postgres12 createdb --username=root --owner=root simple_bank

# Drop simple_bank database:
dropdb:
	docker exec -it postgres12 dropdb simple_bank

# Create a new db migration. eg. "make migration name=init_schema"
# https://github.com/golang-migrate/migrate
# brew install golang-migrate
migration:
	migrate create -ext sql -dir db/migration -seq $(name)

# Run db migration up all versions
migrateup:
	migrate -path db/migration -database "${DB_URL}" -verbose up

# Run db migration up 1 version
migrateup1:
	migrate -path db/migration -database "${DB_URL}" -verbose up 1

# Run db migration down all versions
migratedown:
	migrate -path db/migration -database "${DB_URL}" -verbose down

# Run db migration down 1 version
migratedown1:
	migrate -path db/migration -database "${DB_URL}" -verbose down 1

# Run db migration rollback version
# up 时如果报错，导致迁移失败，其不会更改数据表，但是 schema_migrations version 提升，dirty=True
# 此时需要回退版本
# 1. migrate -path db/migration -database "${DB_URL}" -verbose force 2
#    force 后跟 dirty=True 出错的这个 version
# 2. make migratedown1 回退版本
# 这里合并了以上命令，使用时需: make migraterollback version=2
migraterollback:
	migrate -path db/migration -database "${DB_URL}" -verbose force $(version) \
	& make migratedown1

# Run test
# 查看测试覆盖率 go tool cover -html=coverprofile.out
test:
	go test -v -cover -covermode=count -coverprofile=coverprofile.out ./...

# Run server
# go install -u github.com/cosmtrek/air
dev:
	air -c air.toml

# Run server
# SERVER_ADDRESS=0.0.0.0:8081 make server
server:
	go run main.go

# Generate DB documentation:
dbdocs:
	dbdocs build doc/db.dbml

dbschema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

# proto:
# 	rm -f pb/*.go
# 	protoc \
# 		--proto_path=proto \
# 		--go_out=pb \
# 		--go_opt=paths=source_relative \
# 		--go-grpc_out=pb \
# 		--go-grpc_opt=paths=source_relative \
# 		proto/*.proto
proto:
	rm -f pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc \
		--proto_path=proto \
		--go_out=pb \
		--go_opt=paths=source_relative \
		--go-grpc_out=pb \
		--go-grpc_opt=paths=source_relative \
		--grpc-gateway_out=pb \
		--grpc-gateway_opt=paths=source_relative \
		--openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
		--openapiv2_out=doc/swagger \
		proto/*.proto
	statik -src=./doc/swagger -dest=./doc

# grpc client
evans:
	evans --host localhost --port 9090 -r repl

# 执行 gen.go 里面的生成代码任务
# 1. Generate SQL CRUD with sqlc
# https://github.com/kyleconroy/sqlc
# brew install sqlc
# 
# 2. Generate DB mock with gomock
# https://github.com/golang/mock
# go install github.com/golang/mock/mockgen@v1.6.0
# mock simplebank package 下的 Store interface 到 db/mock/store.go
# mockgen -package=mockdb -destination=db/mock/store.go simplebank/db/sqlc Store
gen:
	go generate ./...


.PHONY: network postgres createdb dropdb makemigration migrateup migratedown migrateup1 migratedown1 migraterollback test dev server dbdocs dbschema proto evans statik gen
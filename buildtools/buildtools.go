//go:build buildtools
// +build buildtools

package buildtools

// 项目中用到的 command 工具, 但是又没有实际导入的, 可以声明在这里, 这样 go mod tidy 就能把依赖写入 go.mod
import (
	_ "github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway"
	_ "github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2"
	_ "github.com/rakyll/statik"
	_ "google.golang.org/grpc/cmd/protoc-gen-go-grpc"
	_ "google.golang.org/protobuf/cmd/protoc-gen-go"
)

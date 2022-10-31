//go:generate sqlc generate
//go:generate mockgen -package=mockdb -destination=db/mock/store.go simplebank/db/sqlc Store
package main

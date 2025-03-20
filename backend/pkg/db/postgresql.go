package db

import (
	"database/sql"
	"errors"
	"sync"

	_ "github.com/lib/pq"
)

var (
	db   *sql.DB
	once sync.Once
)

func ConnectDB(connStr string) (*sql.DB, error) {
	var err error
	once.Do(func() {
		db, err = sql.Open("postgres", connStr)
		if err != nil {
			return
		}
	})
	return db, err
}

func GetDB() (*sql.DB, error) {
	if db == nil {
		return nil, errors.New("there is no connection to the database")
	}
	return db, nil
}

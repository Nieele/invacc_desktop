package db

import (
	"sync"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var (
	db   *gorm.DB
	once sync.Once
)

func GetDB(connStr string) (*gorm.DB, error) {
	var err error
	once.Do(func() {
		db, err = gorm.Open(postgres.Open(connStr), &gorm.Config{})
	})
	return db, err
}

package repository

import (
	"gorm.io/gorm"
)

type RentRepository interface {
}

type rentRepo struct {
	db *gorm.DB
}

func NewRentRepository(db *gorm.DB) RentRepository {
	return &rentRepo{db: db}
}

package repository

import (
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type AuthRepository interface {
	GetCustomerPassword(login string) (string, error)
	InsertCustomer(login, password string) error
}

type authRepo struct {
	db *gorm.DB
}

func NewAuthRepository(db *gorm.DB) AuthRepository {
	return &authRepo{db: db}
}

func (r *authRepo) GetCustomerPassword(login string) (string, error) {
	var customer models.CustomerAuth
	result := r.db.Where("login = ?", login).First(&customer)
	if result.Error != nil {
		return "", result.Error
	}
	return customer.Password, nil
}

func (r *authRepo) InsertCustomer(login, password string) error {
	customer := models.CustomerAuth{
		Login:    login,
		Password: password,
	}
	return r.db.Create(&customer).Error
}

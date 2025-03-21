package repository

import (
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type AuthRepository interface {
	GetCustomerAuth(login string) (models.CustomerAuth, error)
	InsertCustomer(login, password string) error
}

type authRepo struct {
	db *gorm.DB
}

func NewAuthRepository(db *gorm.DB) AuthRepository {
	return &authRepo{db: db}
}

func (r *authRepo) GetCustomerAuth(login string) (models.CustomerAuth, error) {
	var auth models.CustomerAuth
	result := r.db.Where("login = ?", login).First(&auth)
	if result.Error != nil {
		return models.CustomerAuth{}, result.Error
	}
	return auth, nil
}

func (r *authRepo) InsertCustomer(login, password string) error {
	customer := models.CustomerAuth{
		Login:    login,
		Password: password,
	}
	return r.db.Create(&customer).Error
}

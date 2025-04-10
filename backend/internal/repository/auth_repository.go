package repository

import (
	"fmt"
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type AuthRepository interface {
	GetCustomerAuth(login string) (models.CustomerAuth, error)
	// InsertCustomer(login, password string) error // not used
	InsertCustomer(regInfo models.CustomerAuthRegistration) error
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
		return models.CustomerAuth{}, fmt.Errorf("couldn't get customer info by login %s: %w", login, result.Error)
	}
	return auth, nil
}

func (r *authRepo) InsertCustomer(regInfo models.CustomerAuthRegistration) error {
	cAuth := models.CustomerAuth{
		Login:    regInfo.Login,
		Password: regInfo.Password,
	}

	cInfo := models.CustomerInfo{
		FirstName:         regInfo.FirstName,
		LastName:          regInfo.LastName,
		Phone:             regInfo.Phone,
		Phone_verified:    false,
		Email:             regInfo.Email,
		Email_verified:    false,
		Passport:          regInfo.Passport,
		Passport_verified: false,
	}

	tx := r.db.Begin()

	result := tx.Create(&cAuth)
	if result.Error != nil {
		tx.Rollback()
		return fmt.Errorf("couldn't insert customer with login %s: %w", regInfo.Login, result.Error)
	}

	result = tx.Model(&models.CustomerInfo{}).Where("id = ?", cAuth.ID).Updates(&cInfo)
	if result.Error != nil {
		tx.Rollback()
		return fmt.Errorf("couldn't update customer info with id %d: %w", cAuth.ID, result.Error)
	}

	return tx.Commit().Error
}

// func (r *authRepo) InsertCustomer(login, password string) error {
// 	customer := models.CustomerAuth{
// 		Login:    login,
// 		Password: password,
// 	}

// 	result := r.db.Create(&customer)
// 	if result.Error != nil {
// 		return fmt.Errorf("couldn't insert customer with login %s: %w", login, result.Error)
// 	}
// 	return nil
// }

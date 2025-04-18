package repository

import (
	"fmt"
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type CustomerRepository interface {
	GetInfo(id uint) (models.CustomersInfoWithLogin, error)
	UpdateInfo(info models.CustomersInfoWithLogin) error
}

type customerRepo struct {
	db *gorm.DB
}

func NewCustomerRepository(db *gorm.DB) CustomerRepository {
	return &customerRepo{db: db}
}

func (r *customerRepo) GetInfo(id uint) (models.CustomersInfoWithLogin, error) {
	var info models.CustomersInfoWithLogin
	result := r.db.Model(&models.CustomerInfo{}).
		Select("customersinfo.*, customersauth.login").
		Joins("JOIN customersauth ON customersinfo.id = customersauth.id").
		Where("customersinfo.id = ?", id).
		First(&info)

	if result.Error != nil {
		return models.CustomersInfoWithLogin{}, fmt.Errorf("couldn't get customer info by id %d: %w", id, result.Error)
	}

	return info, nil
}

func (r *customerRepo) UpdateInfo(info models.CustomersInfoWithLogin) error {
	tx := r.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	result := tx.Model(&models.CustomerInfo{}).
		Where("id = ?", info.ID).
		Updates(models.CustomerInfo{
			FirstName: info.FirstName,
			LastName:  info.LastName,
			Email:     info.Email,
			Phone:     info.Phone,
			Passport:  info.Passport,
		})

	if result.Error != nil {
		tx.Rollback()
		return fmt.Errorf("couldn't update customer info by id %d: %w", info.ID, result.Error)
	}

	// update login in customersauth table
	result = tx.Model(&models.CustomerAuth{}).
		Where("id = ?", info.ID).
		Updates(models.CustomerAuth{
			Login: info.Login,
		})

	if result.Error != nil {
		tx.Rollback()
		return fmt.Errorf("couldn't update customer info by id %d: %w", info.ID, result.Error)
	}

	if err := tx.Commit().Error; err != nil {
		return fmt.Errorf("couldn't commit transaction: %w", err)
	}

	return nil
}

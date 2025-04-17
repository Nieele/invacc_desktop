package repository

import (
	"fmt"
	"invacc/internal/models"

	"gorm.io/gorm"
)

type CustomerRepository interface {
	GetInfo(id uint) (models.CustomersInfoWithEmail, error)
	UpdateInfo(info models.CustomersInfoWithEmail) error
}

type customerRepo struct {
	db *gorm.DB
}

func NewCustomerRepository(db *gorm.DB) CustomerRepository {
	return &customerRepo{db: db}
}

func (r *customerRepo) GetInfo(id uint) (models.CustomersInfoWithEmail, error) {
	var info models.CustomersInfoWithEmail
	result := r.db.Model(&models.CustomerInfo{}).
		Select("customersinfo.*, customersauth.email").
		Joins("JOIN customersauth ON customersinfo.id = customersauth.id").
		Where("customersinfo.id = ?", id).
		First(&info)

	if result.Error != nil {
		return models.CustomersInfoWithEmail{}, fmt.Errorf("couldn't get customer info by id %d: %w", id, result.Error)
	}

	return info, nil
}

func (r *customerRepo) UpdateInfo(info models.CustomersInfoWithEmail) error {
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
			Email: info.Email,
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

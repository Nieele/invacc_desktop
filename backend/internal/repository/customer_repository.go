package repository

import (
	"fmt"
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type CustomerRepository interface {
	GetInfo(id uint) (models.CustomersInfoWithLogin, error)
	UpdateInfo(info models.CustomerInfo) error
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

func (r *customerRepo) UpdateInfo(info models.CustomerInfo) error {
	result := r.db.Save(&info)
	if result.Error != nil {
		return fmt.Errorf("couldn't update info by id %d: %w", info.ID, result.Error)
	}
	return nil
}

package repository

import (
	"fmt"
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type CustomerRepository interface {
	GetInfo(id uint) (models.CustomerInfo, error)
	UpdateInfo(info models.CustomerInfo) error
}

type customerRepo struct {
	db *gorm.DB
}

func NewCustomerRepository(db *gorm.DB) CustomerRepository {
	return &customerRepo{db: db}
}

func (r *customerRepo) GetInfo(id uint) (models.CustomerInfo, error) {
	var info models.CustomerInfo
	result := r.db.Where("id = ?", id).First(&info)
	if result.Error != nil {
		return models.CustomerInfo{}, fmt.Errorf("couldn't get customer info by id %d: %w", id, result.Error)
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

package repository

import (
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
		return models.CustomerInfo{}, result.Error
	}
	return info, nil
}

func (r *customerRepo) UpdateInfo(info models.CustomerInfo) error {
	if err := r.db.Save(&info).Error; err != nil {
		return err
	}
	return nil
}

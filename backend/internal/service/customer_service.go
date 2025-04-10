package service

import (
	"errors"
	"invacc-backend/internal/models"
	"invacc-backend/internal/repository"

	"gorm.io/gorm"
)

var (
	ErrAccessDenied = errors.New("access denied")
)

type CustomerService interface {
	GetPesonalInfo(userID uint) (models.CustomersInfoWithLogin, error)
	UpdatePersonalInfo(info models.CustomersInfoWithLogin) error
}

type customerService struct {
	customerRepo repository.CustomerRepository
}

func NewCustomerService(db *gorm.DB) CustomerService {
	return &customerService{
		customerRepo: repository.NewCustomerRepository(db),
	}
}

func (s *customerService) GetPesonalInfo(userID uint) (models.CustomersInfoWithLogin, error) {
	return s.customerRepo.GetInfo(userID)
}

func (s *customerService) UpdatePersonalInfo(info models.CustomersInfoWithLogin) error {
	return s.customerRepo.UpdateInfo(info)
}

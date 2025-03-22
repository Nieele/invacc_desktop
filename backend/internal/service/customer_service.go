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
	GetPesonalInfo(token string) (models.CustomerInfo, error)
	UpdatePersonalInfo(token string, info models.CustomerInfo) error
}

type customerService struct {
	customerRepo repository.CustomerRepository
	authService  AuthService
}

func NewCustomerService(db *gorm.DB, authService AuthService) CustomerService {
	return &customerService{
		customerRepo: repository.NewCustomerRepository(db),
		authService:  authService,
	}
}

func (s *customerService) GetPesonalInfo(token string) (models.CustomerInfo, error) {
	userID, err := s.authService.Authentication(token)
	if err != nil {
		return models.CustomerInfo{}, ErrAccessDenied
	}

	return s.customerRepo.GetInfo(userID)
}

func (s *customerService) UpdatePersonalInfo(token string, info models.CustomerInfo) error {
	if _, err := s.authService.Authentication(token); err != nil {
		return ErrAccessDenied
	}

	return s.customerRepo.UpdateInfo(info)
}

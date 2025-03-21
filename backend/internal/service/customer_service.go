package service

import (
	"errors"
	"invacc-backend/internal/models"
	"invacc-backend/internal/repository"

	"gorm.io/gorm"
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
	repo := repository.NewCustomerRepository(db)
	return &customerService{customerRepo: repo, authService: authService}
}

func (s *customerService) GetPesonalInfo(token string) (models.CustomerInfo, error) {
	user_id, err := s.authService.Authentication(token)
	if err != nil {
		return models.CustomerInfo{}, errors.New("access denied")
	}

	info, err := s.customerRepo.GetInfo(user_id)
	if err != nil {
		return models.CustomerInfo{}, err
	}

	return info, nil
}

func (s *customerService) UpdatePersonalInfo(token string, info models.CustomerInfo) error {
	if _, err := s.authService.Authentication(token); err != nil {
		return errors.New("access denied")
	}

	if err := s.customerRepo.UpdateInfo(info); err != nil {
		return err
	}

	return nil
}

package service

import (
	"invacc/internal/models"
	"invacc/internal/repository"

	"gorm.io/gorm"
)

type RentService interface {
	GetCart(CustomerID uint) ([]models.Cart, error)
	AddToCart(cart models.Cart) error
	RemoveFromCart(cart models.Cart) error

	GetRents(CustomerID uint) ([]models.Rent, error)
	Rent(mrent models.MultiRent) error
	CancelRent(CustomerID uint, rentsID uint) error
}

type rentService struct {
	rentRepo repository.RentRepository
}

func NewRentService(db *gorm.DB) RentService {
	repo := repository.NewRentRepository(db)
	return &rentService{rentRepo: repo}
}

func (s *rentService) GetCart(CustomerID uint) ([]models.Cart, error) {
	return s.rentRepo.GetCart(CustomerID)
}

func (s *rentService) AddToCart(cart models.Cart) error {
	return s.rentRepo.AddToCart(cart)
}

func (s *rentService) RemoveFromCart(cart models.Cart) error {
	return s.rentRepo.RemoveFromCart(cart)
}

func (s *rentService) GetRents(CustomerID uint) ([]models.Rent, error) {
	return s.rentRepo.GetRents(CustomerID)
}

func (s *rentService) Rent(mrent models.MultiRent) error {
	return s.rentRepo.Rent(mrent)
}

func (s *rentService) CancelRent(CustomerID uint, rentID uint) error {
	return s.rentRepo.CancelRent(CustomerID, rentID)
}

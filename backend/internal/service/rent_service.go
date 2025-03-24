package service

import (
	"invacc-backend/internal/models"
	"invacc-backend/internal/repository"

	"gorm.io/gorm"
)

type RentService interface {
	GetCart(CustomerID uint) ([]models.Cart, error)
	AddToCart(CustomerID uint, itemID uint) error
	RemoveFromCart(CustomerID uint, itemID uint) error

	Rent(CustomerID uint, itemsID []uint) error
	CancelRent(CustomerID uint, itemsID []uint) error
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

func (s *rentService) AddToCart(CustomerID uint, itemID uint) error {
	return s.rentRepo.AddToCart(CustomerID, itemID)
}

func (s *rentService) RemoveFromCart(CustomerID uint, itemID uint) error {
	return s.rentRepo.RemoveFromCart(CustomerID, itemID)
}

func (s *rentService) Rent(CustomerID uint, itemsID []uint) error {
	return s.rentRepo.Rent(CustomerID, itemsID)
}

func (s *rentService) CancelRent(CustomerID uint, itemsID []uint) error {
	return s.rentRepo.CancelRent(CustomerID, itemsID)
}

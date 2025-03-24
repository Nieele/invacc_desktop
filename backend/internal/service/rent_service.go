package service

import (
	"invacc-backend/internal/models"
	"invacc-backend/internal/repository"

	"gorm.io/gorm"
)

type RentService interface {
	getCart(CustomerID uint) ([]models.Cart, error)
	addToCart(CustomerID uint, itemID uint) error
	removeFromCart(CustomerID uint, itemID uint) error

	rent(CustomerID uint, itemsID []uint) error
	cancelRent(CustomerID uint, itemsID []uint) error
}

type rentService struct {
	rentRepo repository.RentRepository
}

func NewRentService(db *gorm.DB) RentService {
	repo := repository.NewRentRepository(db)
	return &rentService{rentRepo: repo}
}

func (s *rentService) getCart(CustomerID uint) ([]models.Cart, error) {
	return s.rentRepo.GetCart(CustomerID)
}

func (s *rentService) addToCart(CustomerID uint, itemID uint) error {
	return s.rentRepo.AddToCart(CustomerID, itemID)
}

func (s *rentService) removeFromCart(CustomerID uint, itemID uint) error {
	return s.rentRepo.RemoveFromCart(CustomerID, itemID)
}

func (s *rentService) rent(CustomerID uint, itemsID []uint) error {
	return s.rentRepo.Rent(CustomerID, itemsID)
}

func (s *rentService) cancelRent(CustomerID uint, itemsID []uint) error {
	return s.rentRepo.CancelRent(CustomerID, itemsID)
}

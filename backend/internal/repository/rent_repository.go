package repository

import (
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type RentRepository interface {
	getCart(CustomerID uint) ([]models.Cart, error)
	addToCart(CustomerID uint, itemID uint) error
	removeFromCart(CustomerID uint, itemID uint) error
}

type rentRepo struct {
	db *gorm.DB
}

func NewRentRepository(db *gorm.DB) RentRepository {
	return &rentRepo{db: db}
}

func (r *rentRepo) getCart(CustomerID uint) ([]models.Cart, error) {
	var cart []models.Cart
	result := r.db.Model(&models.Cart{}).
		Where("user_id = ?", CustomerID).
		Find(&cart)

	if result.Error != nil {
		return nil, result.Error
	}

	return cart, nil
}

func (r *rentRepo) addToCart(CustomerID uint, itemID uint) error {
	cart := models.Cart{
		CustomerID: CustomerID,
		ItemID:     itemID,
	}
	result := r.db.Create(&cart)

	if result.Error != nil {
		return result.Error
	}

	return nil
}

func (r *rentRepo) removeFromCart(CustomerID uint, itemID uint) error {
	result := r.db.Where("user_id = ? AND item_id = ?", CustomerID, itemID).
		Delete(&models.Cart{})

	if result.Error != nil {
		return result.Error
	}

	return nil
}

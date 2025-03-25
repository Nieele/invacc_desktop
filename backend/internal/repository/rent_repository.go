package repository

import (
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type RentRepository interface {
	GetCart(CustomerID uint) ([]models.Cart, error)
	AddToCart(cart models.Cart) error
	RemoveFromCart(cart models.Cart) error

	Rent(CustomerID uint, itemsID []uint) error
	CancelRent(CustomerID uint, itemsID []uint) error
}

type rentRepo struct {
	db *gorm.DB
}

func NewRentRepository(db *gorm.DB) RentRepository {
	return &rentRepo{db: db}
}

func (r *rentRepo) GetCart(CustomerID uint) ([]models.Cart, error) {
	var cart []models.Cart
	result := r.db.Model(&models.Cart{}).
		Where("customer_id = ?", CustomerID).
		Find(&cart)

	if result.Error != nil {
		return nil, result.Error
	}

	return cart, nil
}

func (r *rentRepo) AddToCart(cart models.Cart) error {
	result := r.db.Create(&cart)

	if result.Error != nil {
		return result.Error
	}

	return nil
}

func (r *rentRepo) RemoveFromCart(cart models.Cart) error {
	result := r.db.Where("customer_id = ? AND item_id = ?", cart.CustomerID, cart.ItemID).
		Delete(&models.Cart{})

	if result.Error != nil {
		return result.Error
	}

	return nil
}

func (r *rentRepo) Rent(CustomerID uint, itemsID []uint) error {
	tx := r.db.Begin()

	for _, itemID := range itemsID {
		rent := models.Rent{
			CustomerID: CustomerID,
			ItemID:     itemID,
		}
		result := tx.Create(&rent)

		if result.Error != nil {
			tx.Rollback()
			return result.Error
		}

	}

	tx.Commit()

	return nil
}

func (r *rentRepo) CancelRent(CustomerID uint, itemsID []uint) error {
	tx := r.db.Begin()

	for _, itemID := range itemsID {
		result := tx.Delete(&models.Rent{}, "customer_id = ? AND item_id = ?", CustomerID, itemID)

		if result.Error != nil {
			tx.Rollback()
			return result.Error
		}

	}

	tx.Commit()

	return nil
}

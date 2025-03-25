package repository

import (
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type RentRepository interface {
	GetCart(CustomerID uint) ([]models.Cart, error)
	AddToCart(cart models.Cart) error
	RemoveFromCart(cart models.Cart) error

	GetRents(CustomerID uint) ([]models.Rent, error)
	Rent(mrent models.MultiRent) error
	CancelRent(CustomerID uint, rentsID []uint) error
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

func (r *rentRepo) GetRents(CustomerID uint) ([]models.Rent, error) {
	var rents []models.Rent
	result := r.db.Model(&models.Rent{}).
		Where("customer_id = ?", CustomerID).
		Find(&rents)

	if result.Error != nil {
		return nil, result.Error
	}

	return rents, nil
}

func (r *rentRepo) Rent(mrent models.MultiRent) error {
	tx := r.db.Begin()

	for _, itemID := range mrent.ItemsID {
		rent := models.Rent{
			CustomerID:   mrent.CustomerID,
			ItemID:       itemID,
			Address:      mrent.Address,
			NumberOfDays: mrent.NumberOfDays,
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

func (r *rentRepo) CancelRent(CustomerID uint, rentsID []uint) error {
	tx := r.db.Begin()

	for _, rentID := range rentsID {
		result := tx.Delete(&models.Rent{}, "customer_id = ? AND id = ?", CustomerID, rentID)

		if result.Error != nil {
			tx.Rollback()
			return result.Error
		}
	}

	tx.Commit()

	return nil
}

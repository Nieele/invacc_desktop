package repository

import (
	"fmt"
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type ItemRepository interface {
	GetItem(id uint) (models.Item, error)
	GetItemsList(page uint) ([]models.Item, error)
}

type itemRepo struct {
	db *gorm.DB
}

func NewItemRepository(db *gorm.DB) ItemRepository {
	return &itemRepo{db: db}
}

func (r *itemRepo) GetItem(id uint) (models.Item, error) {
	var item models.Item
	result := r.db.Where("id = ?", id).First(&item)
	if result.Error != nil {
		return models.Item{}, fmt.Errorf("couldn't find the item with the id %d: %w", id, result.Error)
	}
	return item, nil
}

func (r *itemRepo) GetItemsList(page uint) ([]models.Item, error) {
	const limit = 20
	offset := (page - 1) * limit
	var items []models.Item
	result := r.db.Order("id").Offset(int(offset)).Limit(limit).Find(&items)
	if result.Error != nil {
		return nil, fmt.Errorf("couldn't get list items for page %d: %w", page, result.Error)
	}
	return items, nil
}

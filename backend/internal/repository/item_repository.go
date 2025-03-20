package repository

import (
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type ItemRepository interface {
	GetItem(id int) (models.Item, error)
	GetItemsList(page int) ([]models.Item, error)
}

type itemRepo struct {
	db *gorm.DB
}

func NewItemRepository(db *gorm.DB) ItemRepository {
	return &itemRepo{db: db}
}

func (r *itemRepo) GetItem(id int) (models.Item, error) {
	var item models.Item
	result := r.db.Where("id = ?", id).First(&item)
	if result.Error != nil {
		return models.Item{}, result.Error
	}
	return item, nil
}

func (r *itemRepo) GetItemsList(page int) ([]models.Item, error) {
	var items []models.Item
	result := r.db.Order("id").Offset((page - 1) * 20).Limit(page * 20).Find(&items)
	if result.Error != nil {
		return nil, result.Error
	}
	return items, nil
}

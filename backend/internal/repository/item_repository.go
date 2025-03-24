package repository

import (
	"fmt"
	"invacc-backend/internal/models"

	"gorm.io/gorm"
)

type ItemRepository interface {
	GetItem(id uint) (models.ItemWithWarehouseName, error)
	GetItemsList(page uint) ([]models.ItemWithWarehouseName, error)
}

type itemRepo struct {
	db *gorm.DB
}

func NewItemRepository(db *gorm.DB) ItemRepository {
	return &itemRepo{db: db}
}

func (r *itemRepo) GetItem(id uint) (models.ItemWithWarehouseName, error) {
	var item models.ItemWithWarehouseName
	result := r.db.Model(&models.Item{}).
		Select("items.*, warehouses.name as warehouse_name").
		Joins("JOIN warehouses ON items.warehouse_id = warehouses.id").
		Where("items.id = ?", id).
		First(&item)

	if result.Error != nil {
		return models.ItemWithWarehouseName{}, fmt.Errorf("couldn't find the item with the id %d: %w", id, result.Error)
	}

	return item, nil
}

func (r *itemRepo) GetItemsList(page uint) ([]models.ItemWithWarehouseName, error) {
	const limit = 20
	offset := (page - 1) * limit
	var items []models.ItemWithWarehouseName
	result := r.db.Model(&models.Item{}).
		Select("items.*, warehouses.name as warehouse_name").
		Joins("JOIN warehouses ON items.warehouse_id = warehouses.id").
		Order("items.active DESC").
		Offset(int(offset)).
		Limit(limit).
		Find(&items)

	if result.Error != nil {
		return nil, fmt.Errorf("couldn't get list items for page %d: %w", page, result.Error)
	}

	return items, nil
}

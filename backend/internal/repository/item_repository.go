package repository

import (
	"context"
	"errors"
	"fmt"
	"invacc/internal/models"

	"gorm.io/gorm"
)

var ErrItemNotFound = errors.New("item not found")

// query filters
type ItemFilter struct {
	CategoryID  *uint
	WarehouseID *uint
	Name        *string
}

type ItemRepository interface {
	ListItems(ctx context.Context, filter *ItemFilter, offset, limit int) ([]models.Item, int64, error)
	GetItemByID(ctx context.Context, id uint) (models.Item, error)
}

type itemRepo struct {
	db *gorm.DB
}

func NewItemRepository(db *gorm.DB) ItemRepository {
	return &itemRepo{db: db}
}

func (r *itemRepo) ListItems(ctx context.Context, filter *ItemFilter, offset, limit int) ([]models.Item, int64, error) {
	// prepare the query
	var items []models.Item
	q := r.db.WithContext(ctx).Model(&models.Item{}).
		Preload("Warehouse").
		Preload("Categories").
		Order("items.active DESC")

	// category filter
	if filter.CategoryID != nil {
		// TODO: use gorm's many2many relation?
		q = q.Joins("JOIN itemscategories ic ON ic.item_id = items.id").
			Where("ic.category_id = ?", *filter.CategoryID)
	}

	// warehouse filter
	if filter.WarehouseID != nil {
		q = q.Where("items.warehouse_id = ?", *filter.WarehouseID)
	}

	// name filter
	if filter.Name != nil {
		// TODO: replace ILIKE? Only postgres supports ILIKE
		q = q.Where("items.name ILIKE ?", "%"+*filter.Name+"%")
	}

	// execute the query

	// count total items
	var total int64
	if err := q.Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("count items: %w", err)
	}

	// fetch items
	if err := q.Offset(offset).Limit(limit).Find(&items).Error; err != nil {
		return nil, 0, fmt.Errorf("list items: %w", err)
	}

	return items, total, nil
}

func (r *itemRepo) GetItemByID(ctx context.Context, id uint) (models.Item, error) {
	// execute the query
	var it models.Item
	err := r.db.Model(&models.Item{}).
		Preload("Warehouse").
		Preload("Categories").
		First(&it, id).
		Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return models.Item{}, ErrItemNotFound
		}
		return models.Item{}, fmt.Errorf("get item: %w", err)
	}

	return it, nil
}

package service

import (
	"invacc-backend/internal/models"
	"invacc-backend/internal/repository"

	"gorm.io/gorm"
)

type ItemService interface {
	GetItemModel(id uint) (models.ItemWithWarehouseName, error)
	GetItemModelList(page uint) ([]models.ItemWithWarehouseName, error)
}

type itemService struct {
	itemRepo repository.ItemRepository
}

func NewItemService(db *gorm.DB) ItemService {
	repo := repository.NewItemRepository(db)
	return &itemService{itemRepo: repo}
}

func (s *itemService) GetItemModel(id uint) (models.ItemWithWarehouseName, error) {
	return s.itemRepo.GetItem(id)
}

func (s *itemService) GetItemModelList(page uint) ([]models.ItemWithWarehouseName, error) {
	return s.itemRepo.GetItemsList(page)
}

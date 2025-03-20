package service

import (
	"encoding/json"
	"invacc-backend/internal/repository"

	"gorm.io/gorm"
)

type ItemService interface {
	GetItem(id int) ([]byte, error)
	GetItemsList(page int) ([]byte, error)
}

type itemService struct {
	itemRepo repository.ItemRepository
}

func NewItemService(db *gorm.DB) ItemService {
	repo := repository.NewItemRepository(db)
	return &itemService{itemRepo: repo}
}

func (s *itemService) GetItem(id int) ([]byte, error) {
	item, err := s.itemRepo.GetItem(id)
	if err != nil {
		return nil, err
	}
	return json.Marshal(item)
}

func (s *itemService) GetItemsList(page int) ([]byte, error) {
	items, err := s.itemRepo.GetItemsList(page)
	if err != nil {
		return nil, err
	}
	return json.Marshal(items)
}

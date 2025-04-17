// internal/service/item_service.go
package service

import (
	"context"
	"fmt"
	"invacc/internal/apierrors"
	"invacc/internal/models"
	"invacc/internal/repository"
)

type ItemService interface {
	ListItems(ctx context.Context, filter *repository.ItemFilter, offset, limit int) ([]models.Item, int64, apierrors.Error)
	GetItem(ctx context.Context, id uint) (models.Item, apierrors.Error)
}

type itemService struct {
	repo repository.ItemRepository
}

func NewItemService(r repository.ItemRepository) ItemService {
	return &itemService{r}
}

func (s *itemService) ListItems(ctx context.Context, filter *repository.ItemFilter, offset, limit int) ([]models.Item, int64, apierrors.Error) {
	items, total, err := s.repo.ListItems(ctx, filter, offset, limit)

	if err != nil {
		return nil, 0, apierrors.NewInternalError(err)
	}

	return items, total, nil
}

func (s *itemService) GetItem(ctx context.Context, id uint) (models.Item, apierrors.Error) {
	it, err := s.repo.GetItemByID(ctx, id)

	if err != nil {
		if err == repository.ErrItemNotFound {
			return models.Item{}, apierrors.NewNotFoundError("item_not_found", fmt.Sprintf("Item %d not found", id))
		}
		return models.Item{}, apierrors.NewInternalError(err)
	}

	return it, nil
}

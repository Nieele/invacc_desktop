package handlers

import (
	"net/http"

	"invacc-backend/internal/service"
)

type ItemHandler interface {
	GetItems(w http.ResponseWriter, r *http.Request)
}

type itemHandler struct {
	itemService service.ItemService
}

func NewItemHandler(itemService service.ItemService) ItemHandler {
	return &itemHandler{itemService: itemService}
}

func (h *itemHandler) GetItems(w http.ResponseWriter, r *http.Request) {

}

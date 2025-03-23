package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"invacc-backend/internal/models"
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
	w.Header().Set("Content-Type", "application/json")

	query := r.URL.Query()
	if id := query.Get("id"); id != "" {
		h.handleGetItemById(w, id)
		return
	}

	if page := query.Get("page"); page != "" {
		h.handleGetItemsByPage(w, page)
		return
	}

	http.Error(w, "either 'id' or 'page' query parameter must be provided", http.StatusBadRequest)
}

func (h *itemHandler) handleGetItemById(w http.ResponseWriter, idParam string) {
	id, err := strconv.ParseUint(idParam, 10, 32)
	if err != nil {
		http.Error(w, "invalid id parameter", http.StatusBadRequest)
		return
	}

	item, err := h.itemService.GetItemModel(uint(id))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	encodeResponse(w, item)
}

func (h *itemHandler) handleGetItemsByPage(w http.ResponseWriter, pageParam string) {
	page, err := strconv.ParseUint(pageParam, 10, 32)
	if err != nil || page < 1 {
		http.Error(w, "invalid page parameter", http.StatusBadRequest)
		return
	}

	items, err := h.itemService.GetItemModelList(uint(page))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	response := struct {
		Count int           `json:"count"`
		Items []models.Item `json:"items"`
	}{
		Count: len(items),
		Items: items,
	}

	encodeResponse(w, response)
}

func encodeResponse(w http.ResponseWriter, data interface{}) {
	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, "failed to encode response", http.StatusInternalServerError)
	}
}

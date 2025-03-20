package handlers

import (
	"net/http"
	"strconv"
	"text/template"

	"invacc-backend/internal/service"
)

type ItemHandler interface {
	GetItemPage(w http.ResponseWriter, r *http.Request)
}

type itemHandler struct {
	itemService service.ItemService
}

func NewItemHandler(itemService service.ItemService) ItemHandler {
	return &itemHandler{itemService: itemService}
}

func (h *itemHandler) GetItemPage(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		http.Error(w, "id parameter is required", http.StatusBadRequest)
		return
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "invalid id parameter", http.StatusBadRequest)
		return
	}

	item, err := h.itemService.GetItemModel(id)
	if err != nil {
		http.Error(w, "item not found", http.StatusNotFound)
		return
	}

	tmpl, err := template.ParseFiles("templates/item.html")
	if err != nil {
		http.Error(w, "error loading template", http.StatusInternalServerError)
		return
	}

	err = tmpl.Execute(w, item)
	if err != nil {
		http.Error(w, "error rendering template", http.StatusInternalServerError)
		return
	}
}

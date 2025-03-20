package handlers

import (
	"log"
	"net/http"
	"strconv"
	"text/template"

	"invacc-backend/internal/models"
	"invacc-backend/internal/service"
)

type ItemHandler interface {
	GetItemPage(w http.ResponseWriter, r *http.Request)
	GetItemsListPage(w http.ResponseWriter, r *http.Request)
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

func (h *itemHandler) GetItemsListPage(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// extract page (default 1)
	pageStr := r.URL.Query().Get("page")
	page := 1
	if pageStr != "" {
		if p, err := strconv.Atoi(pageStr); err == nil && p > 0 {
			page = p
		}
	}

	items, err := h.itemService.GetItemModelList(page)
	if err != nil {
		http.Error(w, "error fetching items", http.StatusInternalServerError)
		return
	}

	// cutting off the description
	funcMap := template.FuncMap{
		"truncate": func(s string, max int) string {
			if len(s) <= max {
				return s
			}
			return s[:max] + "..."
		},
	}

	// uploading the template index.html
	tmpl, err := template.New("index.html").Funcs(funcMap).ParseFiles("templates/index.html")
	if err != nil {
		http.Error(w, "error loading template", http.StatusInternalServerError)
		return
	}

	// preparing the data for the template
	data := struct {
		Items []models.Item
		Page  int
	}{
		Items: items,
		Page:  page,
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	err = tmpl.Execute(w, data)
	if err != nil {
		log.Fatal(err)
		http.Error(w, "error rendering template", http.StatusInternalServerError)
		return
	}
}

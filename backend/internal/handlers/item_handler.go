package handlers

import (
	"encoding/json"
	"net/http"
	"net/url"
	"strconv"

	"github.com/go-chi/chi/v5"

	"invacc/internal/apierrors"
	"invacc/internal/repository"
	"invacc/internal/service"
)

type ItemHandler struct {
	svc service.ItemService
}

func NewItemHandler(svc service.ItemService) *ItemHandler {
	return &ItemHandler{svc: svc}
}

// ListItems godoc
// @Summary     List items
// @Description Returns a paginated list of items with optional filtering by category, warehouse, and name.
// @Tags        items
// @Accept      json
// @Produce     json
// @Param       page         query   int     false  "Page number"       default(1)
// @Param       limit        query   int     false  "Page size"         default(20)
// @Param       category_id  query   int     false  "Category ID to filter by"
// @Param       warehouse_id query   int     false  "Warehouse ID to filter by"
// @Param       name         query   string  false  "Search substring in name"
// @Success     200 {object} handlers.PaginatedResponse
// @Failure     400 {object} handlers.ErrorResponse
// @Failure     500 {object} handlers.ErrorResponse
// @Router      /items [get]
func (h *ItemHandler) ListItems(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	q := r.URL.Query()

	// Pagination
	// Read page and limit from query parameters
	// Default values: page=1, limit=20
	page, _ := strconv.Atoi(q.Get("page"))
	if page < 1 {
		page = 1
	}

	limit, _ := strconv.Atoi(q.Get("limit"))
	if limit < 1 {
		limit = 20
	}

	offset := (page - 1) * limit

	// Filtering
	// Read category_id
	filter := &repository.ItemFilter{}
	if v := q.Get("category_id"); v != "" {
		id, err := strconv.ParseUint(v, 10, 32)
		if err != nil {
			writeError(w, apierrors.NewBadRequestError("invalid_query", "category_id must be uint", nil))
			return
		}
		u := uint(id)
		filter.CategoryID = &u
	}

	// Read warehouse_id
	if v := q.Get("warehouse_id"); v != "" {
		id, err := strconv.ParseUint(v, 10, 32)
		if err != nil {
			writeError(w, apierrors.NewBadRequestError("invalid_query", "warehouse_id must be uint", nil))
			return
		}
		u := uint(id)
		filter.WarehouseID = &u
	}

	// Read name
	if v := q.Get("name"); v != "" {
		filter.Name = &v
	}

	// Call service layer
	items, total, err := h.svc.ListItems(ctx, filter, offset, limit)
	if err != nil {
		writeError(w, err)
		return
	}

	// Build DTO response
	var data []ItemDTO
	for _, it := range items {
		data = append(data, ItemDTO{
			ID:            it.ID,
			Name:          it.Name,
			Price:         it.Price,
			WarehouseID:   it.Warehouse.ID,
			WarehouseName: it.Warehouse.Name,
			ImgURL:        it.ImgURL,
		})
	}

	// Build pagination metadata
	// TODO: rewrite

	// Save parameters and path
	orig := r.URL.Query()
	base := r.URL.Path + "?"

	// Create map parameters, change page and limit, generate link
	makeLink := func(p int) string {
		q := url.Values{}
		for k, vs := range orig {
			for _, v := range vs {
				q.Add(k, v)
			}
		}
		q.Set("page", strconv.Itoa(p))
		q.Set("limit", strconv.Itoa(limit))
		return base + q.Encode()
	}

	meta := map[string]interface{}{
		"page":  page,
		"limit": limit,
		"total": total,
	}

	links := map[string]string{
		"self": makeLink(page),
		"prev": "",
		"next": makeLink(page + 1),
	}

	if page > 1 {
		links["prev"] = makeLink(page - 1)
	}

	writeJSON(w, http.StatusOK,
		map[string]interface{}{
			"data":  data,
			"meta":  meta,
			"links": links,
		})
}

// GetItem godoc
// @Summary     Get item details by ID
// @Description Returns full details of a single item, including warehouse and categories.
// @Tags        items
// @Accept      json
// @Produce     json
// @Param       id   path      int  true  "Item ID"
// @Success     200 {object} handlers.ItemDetailResponse
// @Failure     400 {object} handlers.ErrorResponse
// @Failure     404 {object} handlers.ErrorResponse
// @Failure     500 {object} handlers.ErrorResponse
// @Router      /items/{id} [get]
func (h *ItemHandler) GetItem(w http.ResponseWriter, r *http.Request) {
	// Parse ID from URL
	ctx := r.Context()
	idStr := chi.URLParam(r, "id")
	id64, err := strconv.ParseUint(idStr, 10, 32)

	if err != nil {
		writeError(w, apierrors.NewBadRequestError("invalid_id", "id must be uint", nil))
		return
	}

	// Call service layer
	it, err := h.svc.GetItem(ctx, uint(id64))
	if err != nil {
		writeError(w, err)
		return
	}

	// Make DTO response

	// Parse categories, make Category DTO
	catsDTO := make([]CategoryDTO, len(it.Categories))
	for i, c := range it.Categories {
		catsDTO[i] = CategoryDTO{ID: c.ID, CategoryName: c.CategoryName}
	}

	// Parse warehouse, make Warehouse DTO
	whDTO := WarehouseDTO{
		ID:      it.Warehouse.ID,
		Name:    it.Warehouse.Name,
		Phone:   it.Warehouse.Phone,
		Email:   it.Warehouse.Email,
		Address: it.Warehouse.Address,
		Active:  it.Warehouse.Active,
	}

	// Parse extra attributes
	extraAttrs := make(map[string]interface{})
	if it.ExtraAttributes != nil {
		if err := json.Unmarshal(it.ExtraAttributes, &extraAttrs); err != nil {
			writeError(w, apierrors.NewInternalError(err))
			return
		}
	}

	// Build response
	detail := ItemDetailDTO{
		ID:              it.ID,
		Name:            it.Name,
		Description:     it.Description,
		ExtraAttributes: extraAttrs,
		Quality:         it.Quality,
		Price:           it.Price,
		LatePenalty:     it.LatePenalty,
		Deposit:         it.Deposit,
		Active:          it.Active,
		ImgURL:          it.ImgURL,
		Warehouse:       whDTO,
		Categories:      catsDTO,
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{"data": detail})
}

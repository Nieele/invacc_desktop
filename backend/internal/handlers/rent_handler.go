package handlers

import (
	"encoding/json"
	"invacc-backend/internal/middleware"
	"invacc-backend/internal/models"
	"invacc-backend/internal/service"
	"net/http"
)

type RentHandler interface {
	GetCart(w http.ResponseWriter, r *http.Request)
	AddToCart(w http.ResponseWriter, r *http.Request)
	RemoveFromCart(w http.ResponseWriter, r *http.Request)

	Rent(w http.ResponseWriter, r *http.Request)
	CancelRent(w http.ResponseWriter, r *http.Request)
}

type rentHandler struct {
	rentService service.RentService
}

func NewRentHandler(rentService service.RentService) RentHandler {
	return &rentHandler{rentService: rentService}
}

// GET /cart
func (h *rentHandler) GetCart(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID, ok := r.Context().Value(middleware.UserCtxKey).(uint)
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	cartItems, err := h.rentService.GetCart(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(cartItems)
}

// POST /cart. body: {"item_id": 123}
func (h *rentHandler) AddToCart(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID, ok := r.Context().Value(middleware.UserCtxKey).(uint)
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	// TODO: make model
	var payload struct {
		ItemID uint `json:"item_id"`
	}

	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&payload); err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	cart := models.Cart{
		CustomerID: userID,
		ItemID:     payload.ItemID,
	}

	if err := h.rentService.AddToCart(cart); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "item added to cart"})
}

// DELETE /cart. body: {"item_id": 123}
func (h *rentHandler) RemoveFromCart(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodDelete {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID, ok := r.Context().Value(middleware.UserCtxKey).(uint)
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	// TODO: make model
	var payload struct {
		ItemID uint `json:"item_id"`
	}

	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&payload); err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	cart := models.Cart{
		CustomerID: userID,
		ItemID:     payload.ItemID,
	}

	if err := h.rentService.RemoveFromCart(cart); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "item removed from cart"})
}

// POST /rent/confirm {"items_id": [101, 102, 103]}
func (h *rentHandler) Rent(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID, ok := r.Context().Value(middleware.UserCtxKey).(uint)
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	// TODO: make model
	var payload struct {
		ItemsID []uint `json:"items_id"`
	}

	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&payload); err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	if err := h.rentService.Rent(userID, payload.ItemsID); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "rent confirmed"})
}

// DELETE /rent/cancel {"items_id": [101, 102]}
func (h *rentHandler) CancelRent(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodDelete {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID, ok := r.Context().Value(middleware.UserCtxKey).(uint)
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	// TODO: make model
	var payload struct {
		ItemsID []uint `json:"items_id"`
	}

	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&payload); err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	if err := h.rentService.CancelRent(userID, payload.ItemsID); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "rent canceled"})
}

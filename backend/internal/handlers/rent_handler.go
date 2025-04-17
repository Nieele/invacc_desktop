package handlers

import (
	"encoding/json"
	"invacc/internal/middleware"
	"invacc/internal/models"
	"invacc/internal/service"
	"net/http"
)

type RentHandler interface {
	GetCart(w http.ResponseWriter, r *http.Request)
	AddToCart(w http.ResponseWriter, r *http.Request)
	RemoveFromCart(w http.ResponseWriter, r *http.Request)

	GetRents(w http.ResponseWriter, r *http.Request)
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

// @Summary      Get list rents
// @Description  Return list of rents
// @Tags         rent
// @Produce      json
// @Success      200  {array}   RentDTO
// @Router       /rents [get]
func (h *rentHandler) GetRents(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID, ok := r.Context().Value(middleware.UserCtxKey).(uint)
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	rents, err := h.rentService.GetRents(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rentDTOs := make([]RentDTO, 0, len(rents))
	for _, rent := range rents {
		dto := RentDTO{
			ID:                 rent.ID,
			ItemID:             rent.ItemID,
			ItemName:           rent.Item.Name,
			ItemImgURL:         rent.Item.ImgURL,
			NumberOfDays:       rent.NumberOfDays,
			Address:            rent.Address,
			DeliveryStatusName: rent.DeliveryStatus.Description,
			Overdue:            rent.Overdue,
		}
		// TotalPrice в модели — *float64, в DTO — float64
		if rent.TotalPayments != nil {
			dto.TotalPrice = *rent.TotalPayments
		}
		rentDTOs = append(rentDTOs, dto)
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(rentDTOs); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// POST /rent {"item_id": [], "address": "", "number_of_days": }
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

	mrent_nonID := models.MultiRentWithoutCustomerID{}

	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&mrent_nonID); err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	mrent := models.MultiRent{
		CustomerID:   userID,
		ItemsID:      mrent_nonID.ItemsID,
		Address:      mrent_nonID.Address,
		NumberOfDays: mrent_nonID.NumberOfDays,
	}

	if err := h.rentService.Rent(mrent); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "rent confirmed"})
}

// DELETE /rent {"rents_id": 1}
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
		RentsID []uint `json:"rents_id"`
	}

	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&payload); err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	if err := h.rentService.CancelRent(userID, payload.RentsID); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "rent canceled"})
}

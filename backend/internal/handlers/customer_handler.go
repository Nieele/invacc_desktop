package handlers

import (
	"encoding/json"
	"net/http"

	"invacc/internal/middleware"
	"invacc/internal/models"
	"invacc/internal/service"
)

type CustomerHandler interface {
	GetPesonalInfo(w http.ResponseWriter, r *http.Request)
	UpdatePesonalInfo(w http.ResponseWriter, r *http.Request)
}
type customerHandler struct {
	customerService service.CustomerService
}

func NewCustomerHandler(customerService service.CustomerService) CustomerHandler {
	return &customerHandler{customerService: customerService}
}

func (h *customerHandler) UpdatePesonalInfo(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID, ok := r.Context().Value(middleware.UserCtxKey).(uint)
	if !ok {
		http.Error(w, "Необходима авторизация", http.StatusUnauthorized)
		return
	}

	var info models.CustomersInfoWithEmail
	if err := json.NewDecoder(r.Body).Decode(&info); err != nil {
		http.Error(w, "invalid request payload", http.StatusBadRequest)
		return
	}

	info.ID = userID

	if err := h.customerService.UpdatePersonalInfo(info); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/json")
	response := map[string]string{"message": "personal info updated"}
	json.NewEncoder(w).Encode(response)
}

func (h *customerHandler) GetPesonalInfo(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID, ok := r.Context().Value(middleware.UserCtxKey).(uint)
	if !ok {
		http.Error(w, "Необходима авторизация", http.StatusUnauthorized)
		return
	}

	personalInfo, err := h.customerService.GetPesonalInfo(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(personalInfo)
	w.WriteHeader(http.StatusOK)
}

package handlers

import (
	"encoding/json"
	"net/http"

	"invacc-backend/internal/service"
)

type CustomerHandler interface {
	GetPesonalInfo(w http.ResponseWriter, r *http.Request)
}
type customerHandler struct {
	customerService service.CustomerService
}

func NewCustomerHandler(customerService service.CustomerService) CustomerHandler {
	return &customerHandler{customerService: customerService}
}

func (h *customerHandler) GetPesonalInfo(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	var request struct {
		ID int `json:"id"`
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	cookie, err := r.Cookie("token")
	if err != nil {
		http.Error(w, "token not found in cookies", http.StatusUnauthorized)
		return
	}

	personalInfo, err := h.customerService.GetPesonalInfo(request.ID, cookie.Value)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(personalInfo)
}

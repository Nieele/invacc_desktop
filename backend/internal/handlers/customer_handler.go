package handlers

import (
	"encoding/json"
	"net/http"

	"invacc-backend/internal/middleware"
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

	userID, ok := r.Context().Value(middleware.UserCtxKey).(uint)
	if !ok {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return
	}

	personalInfo, err := h.customerService.GetPesonalInfo(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(personalInfo)
}

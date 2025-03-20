package handlers

import (
	"encoding/json"
	"net/http"
	"time"

	"invacc-backend/internal/models"
	"invacc-backend/internal/service"
)

type AuthHandler interface {
	Register(w http.ResponseWriter, r *http.Request)
	Login(w http.ResponseWriter, r *http.Request)
}

type authHandler struct {
	authService service.AuthService
}

func NewAuthHandler(authService service.AuthService) AuthHandler {
	return &authHandler{authService: authService}
}

func (h *authHandler) Register(w http.ResponseWriter, r *http.Request) {
	// repeat code? TODO
	if r.Method != http.MethodPost {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	var creds models.Credentials
	err := json.NewDecoder(r.Body).Decode(&creds)
	if err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	err = h.authService.Registration(creds)
	if err != nil {
		http.Error(w, "user already exists", http.StatusConflict)
	}
}

func (h *authHandler) Login(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	var creds models.Credentials
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	token, err := h.authService.Authorization(creds)
	if err != nil {
		http.Error(w, "incorrect login/password", http.StatusUnauthorized)
		return
	}

	// setup cookie with jwt token
	cookie := &http.Cookie{
		Name:     "token",
		Value:    token,
		Expires:  time.Now().Add(24 * time.Hour),
		HttpOnly: true,
	}
	http.SetCookie(w, cookie)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"token": token})
}

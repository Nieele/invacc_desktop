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
	Logout(w http.ResponseWriter, r *http.Request)
}

type authHandler struct {
	authService service.AuthService
}

func NewAuthHandler(authService service.AuthService) AuthHandler {
	return &authHandler{authService: authService}
}

func (h *authHandler) Register(w http.ResponseWriter, r *http.Request) {
	// TODO: repeat code? (Login)
	if r.Method != http.MethodPost {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	var creds models.CustomerAuthRegistration
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&creds); err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	if err := h.authService.Register(creds); err != nil {
		http.Error(w, "user already exists", http.StatusConflict)
		return
	}
}

func (h *authHandler) Login(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	var creds models.CustomerAuth
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&creds); err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	token, err := h.authService.Login(creds)
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

func (h *authHandler) Logout(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	cookie := &http.Cookie{
		Name:     "token",
		Value:    "",
		Expires:  time.Now().Add(-time.Hour),
		HttpOnly: true,
	}
	http.SetCookie(w, cookie)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "logged out"})
}

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
	GetLoginPage(w http.ResponseWriter, r *http.Request)
	GetRegisterPage(w http.ResponseWriter, r *http.Request)
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

	var creds models.CustomerAuth
	err := json.NewDecoder(r.Body).Decode(&creds)
	if err != nil {
		http.Error(w, "incorrect format data", http.StatusBadRequest)
		return
	}

	// TODO: add validation (github.com/go-playground/validator/v10)
	if len(creds.Login) < 4 || len(creds.Password) < 4 {
		http.Error(w, "login or password less than 4", http.StatusBadRequest)
		return
	}

	err = h.authService.Register(creds)
	if err != nil {
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
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
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

func (h *authHandler) GetLoginPage(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	http.ServeFile(w, r, "templates/login.html")
}

func (h *authHandler) GetRegisterPage(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method is not allowed", http.StatusMethodNotAllowed)
		return
	}

	http.ServeFile(w, r, "templates/register.html")
}

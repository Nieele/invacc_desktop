package app

import (
	"net/http"

	"invacc-backend/internal/config"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func NewRouter(dbConn *gorm.DB, cfg *config.Config) http.Handler {
	r := chi.NewRouter()

	// Initialize services

	// Initialize handlers

	// Register routes

	return r
}

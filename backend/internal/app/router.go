package app

import (
	"net/http"

	"invacc-backend/internal/config"
	"invacc-backend/internal/handlers"
	"invacc-backend/internal/service"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func NewRouter(dbConn *gorm.DB, cfg *config.Config) http.Handler {
	r := chi.NewRouter()

	// Initialize services
	AuthService := service.NewAuthService(dbConn, []byte(cfg.JWT.SecretKey))
	ItemService := service.NewItemService(dbConn)

	// Initialize handlers
	AuthHandler := handlers.NewAuthHandler(AuthService)
	ItemHandler := handlers.NewItemHandler(ItemService)

	// Register routes
	r.Post("/register", AuthHandler.Register)
	r.Post("/login", AuthHandler.Login)
	r.Get("/item", ItemHandler.GetItemPage)
	r.Get("/", ItemHandler.GetItemsListPage)

	return r
}

package app

import (
	"net/http"

	"invacc-backend/internal/config"
	"invacc-backend/internal/handlers"
	"invacc-backend/internal/service"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"gorm.io/gorm"
)

func NewRouter(dbConn *gorm.DB, cfg *config.Config) http.Handler {
	r := chi.NewRouter()

	r.Use(middleware.Logger)
	r.Use(middleware.Heartbeat("/ping"))

	// Initialize services
	AuthService := service.NewAuthService(dbConn, cfg.Auth)
	ItemService := service.NewItemService(dbConn)
	CostumerService := service.NewCustomerService(dbConn, AuthService)

	// Initialize handlers
	AuthHandler := handlers.NewAuthHandler(AuthService)
	ItemHandler := handlers.NewItemHandler(ItemService)
	CostumerHandler := handlers.NewCustomerHandler(CostumerService)

	// Register routes
	r.Post("/register", AuthHandler.Register)
	r.Post("/login", AuthHandler.Login)
	r.Get("/register", AuthHandler.GetRegisterPage)
	r.Get("/login", AuthHandler.GetLoginPage)
	r.Get("/item", ItemHandler.GetItemPage)
	r.Get("/", ItemHandler.GetItemsListPage)
	r.Get("/account", CostumerHandler.GetPesonalInfo)

	return r
}

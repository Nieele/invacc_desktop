package app

import (
	"net/http"

	"invacc-backend/internal/config"
	"invacc-backend/internal/handlers"
	custommw "invacc-backend/internal/middleware"
	"invacc-backend/internal/service"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"gorm.io/gorm"
)

func NewRouter(dbConn *gorm.DB, cfg *config.Config) http.Handler {
	r := chi.NewRouter()

	// Use chi middleware
	r.Use(middleware.Logger)
	r.Use(middleware.Heartbeat("/ping"))

	// Initialize services
	AuthService := service.NewAuthService(dbConn, cfg.Auth)
	ItemService := service.NewItemService(dbConn)
	CostumerService := service.NewCustomerService(dbConn)
	RentService := service.NewRentService(dbConn)

	// Initialize handlers
	AuthHandler := handlers.NewAuthHandler(AuthService)
	ItemHandler := handlers.NewItemHandler(ItemService)
	CostumerHandler := handlers.NewCustomerHandler(CostumerService)
	RentHandler := handlers.NewRentHandler(RentService)

	// Register routes
	r.Post("/register", AuthHandler.Register)
	r.Post("/login", AuthHandler.Login)
	r.Post("/logout", AuthHandler.Logout)
	r.Get("/items", ItemHandler.GetItems)
	r.Group(func(r chi.Router) {
		r.Use(custommw.JWTAuthMiddleware(AuthService))
		r.Get("/account", CostumerHandler.GetPesonalInfo)
		r.Get("/cart", RentHandler.GetCart)
		r.Post("/cart", RentHandler.AddToCart)
		r.Delete("/cart", RentHandler.RemoveFromCart)
		r.Get("/rent", RentHandler.GetRents)
		r.Post("/rent", RentHandler.Rent)
		r.Delete("/rent", RentHandler.CancelRent)
	})

	return r
}

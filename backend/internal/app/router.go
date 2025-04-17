package app

import (
	"net/http"

	"invacc/internal/config"
	"invacc/internal/handlers"
	custommw "invacc/internal/middleware"
	"invacc/internal/repository"
	"invacc/internal/service"

	_ "invacc/docs"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	httpSwagger "github.com/swaggo/http-swagger"
	"gorm.io/gorm"
)

func NewRouter(db *gorm.DB, cfg *config.Config) http.Handler {
	r := chi.NewRouter()

	// Use chi middleware
	r.Use(middleware.Logger)
	r.Use(middleware.Heartbeat("/ping"))

	// Initialize repositories
	ItemRepo := repository.NewItemRepository(db)

	// Initialize services
	AuthService := service.NewAuthService(db, cfg.Auth)
	ItemService := service.NewItemService(ItemRepo)
	CostumerService := service.NewCustomerService(db)
	RentService := service.NewRentService(db)

	// Initialize handlers
	AuthHandler := handlers.NewAuthHandler(AuthService)
	ItemHandler := handlers.NewItemHandler(ItemService)
	CostumerHandler := handlers.NewCustomerHandler(CostumerService)
	RentHandler := handlers.NewRentHandler(RentService)

	// Register routes
	r.Post("/register", AuthHandler.Register)
	r.Post("/login", AuthHandler.Login)
	r.Post("/logout", AuthHandler.Logout)

	r.Get("/items", ItemHandler.ListItems)
	r.Get("/items/{id}", ItemHandler.GetItem)

	r.Get("/swagger/*", httpSwagger.WrapHandler)

	r.Group(func(r chi.Router) {
		r.Use(custommw.JWTAuthMiddleware(AuthService))
		r.Get("/account", CostumerHandler.GetPesonalInfo)
		r.Put("/account", CostumerHandler.UpdatePesonalInfo)
		r.Get("/cart", RentHandler.GetCart)
		r.Post("/cart", RentHandler.AddToCart)
		r.Delete("/cart", RentHandler.RemoveFromCart)
		r.Get("/rents", RentHandler.GetRents)
		r.Post("/rents", RentHandler.Rent)
		r.Delete("/rents", RentHandler.CancelRent)
	})

	return r
}

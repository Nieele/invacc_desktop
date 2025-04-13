package main

import (
	"invacc-backend/internal/app"
	"invacc-backend/internal/config"
	"invacc-backend/internal/logger"
	"invacc-backend/pkg/db"
	"invacc-backend/pkg/valid"
	"log/slog"
	"net/http"
	"os"
	"strconv"
)

func main() {
	slog.Info("starting server")

	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		slog.Error("failed to load config", "error", err)
		os.Exit(1)
	}
	slog.Info("configuration loaded")

	// Initialize logger
	err = logger.Init(cfg)
	if err != nil {
		slog.Error("failed to initialize logger", "error", err)
		os.Exit(1)
	}
	slog.Info("logger initialized")

	// Initialize validator
	valid.Init()
	slog.Info("validator initialized")

	// Initialize database connection
	dbConn, err := db.GetDB(config.GetConnStringDB())
	if err != nil {
		slog.Error("database connection error", "error", err)
		os.Exit(1)
	}
	slog.Info("database connection established")

	// defer closing the database connection
	defer func() {
		if err := db.CloseConnection(); err != nil {
			slog.Error("failed to close database connection", "error", err)
		} else {
			slog.Info("database connection closed")
		}
	}()

	// Initialize the router
	router := app.NewRouter(dbConn, cfg)

	// Start the server
	addr := cfg.HTTPServer.Address + ":" + strconv.Itoa(cfg.HTTPServer.Port)
	slog.Info("server is starting",
		"address", cfg.HTTPServer.Address,
		"port", cfg.HTTPServer.Port)

	if err := http.ListenAndServe(addr, router); err != nil {
		slog.Error("server failed to start", "error", err)
		os.Exit(1)
	}
}

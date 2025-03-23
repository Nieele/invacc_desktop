package main

import (
	"invacc-backend/internal/app"
	"invacc-backend/internal/config"
	"invacc-backend/pkg/db"
	"log"
	"net/http"
	"strconv"
)

func main() {
	log.Println("run server")

	cfg, err := config.LoadConfig()
	if err != nil {
		panic("config is not load")
	}

	dbConn, err := db.GetDB(config.GetConnStringDB())
	if err != nil {
		log.Fatal("database connection error")
	}

	router := app.NewRouter(dbConn, cfg)

	addr := cfg.HTTPServer.Address + ":" + strconv.Itoa(cfg.HTTPServer.Port)
	log.Fatal(http.ListenAndServe(addr, router))

	log.Println("server is up", cfg.HTTPServer.Address, ":", cfg.HTTPServer.Port)
}

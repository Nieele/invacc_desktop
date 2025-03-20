package main

import (
	"invacc-backend/internal/config"
	"log"
)

func main() {
	log.Println("run server")

	cfg, err := config.LoadConfig()
	if err != nil {
		panic("config is not load")
	}

	log.Println(cfg)
}

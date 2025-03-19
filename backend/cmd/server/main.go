package main

import (
	"invacc-backend/internal/config"
	"log"
)

func main() {
	log.Println("run server")

	cfg, err := config.Load()
	if err != nil {
		panic("config is not load")
	}

	log.Println(cfg)
}

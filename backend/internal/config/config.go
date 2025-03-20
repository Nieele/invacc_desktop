// internal/config/config.go

package config

import (
	"errors"
	"flag"
	"log"
	"os"
	"sync"
	"time"

	"gopkg.in/yaml.v3"
)

type Config struct {
	Env        string `yaml:"env"`
	Database   `yaml:"database"`
	HTTPServer `yaml:"http_server"`
	JWT        `yaml:"jwt"`
}

type Database struct {
	Username string `yaml:"username"`
	Password string `yaml:"password"`
	Address  string `yaml:"address"`
	Port     int    `yaml:"port"`
	DbName   string `yaml:"dbName"`
	Sslmode  string `yaml:"sslmode"`
}

type HTTPServer struct {
	Address     string        `yaml:"address"`
	Port        int           `yaml:"port"`
	Timeout     time.Duration `yaml:"timeout"`
	IdleTimeout time.Duration `yaml:"idle_timeout"`
}

type JWT struct {
	SecretKey string `yaml:"secretKey"`
}

var (
	cfg  *Config
	once sync.Once
)

func LoadConfig() (*Config, error) {
	var err error
	once.Do(func() {
		configPath := flag.String("config", "configs/config.yaml", "path to config file")
		flag.Parse()

		data, err2 := os.ReadFile(*configPath)
		if err2 != nil {
			log.Fatalf("Error reading config file: %v", err2)
			err = err2
			return
		}

		var c Config
		if err2 = yaml.Unmarshal(data, &c); err2 != nil {
			log.Fatalf("Error parsing YAML: %v", err2)
			err = err2
			return
		}

		cfg = &c
	})
	return cfg, err
}

func GetConfig() (*Config, error) {
	if cfg == nil {
		return nil, errors.New("config is not loaded; call LoadConfig first")
	}
	return cfg, nil
}

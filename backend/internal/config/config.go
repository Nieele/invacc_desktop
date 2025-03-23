// internal/config/config.go

package config

import (
	"errors"
	"flag"
	"log"
	"os"
	"strconv"
	"sync"
	"time"

	"gopkg.in/yaml.v3"
)

type Config struct {
	Env        string `yaml:"env"`
	Database   `yaml:"database"`
	HTTPServer `yaml:"http_server"`
	Auth       `yaml:"auth"`
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

type Auth struct {
	JWTSecretKey string        `yaml:"jwt_secret"`
	TokenExpiry  time.Duration `yaml:"token_expiry"`
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

func GetConnStringDB() string {
	return "postgres://" + cfg.Database.Username + ":" + cfg.Database.Password + "@" + cfg.Database.Address + ":" + strconv.Itoa(cfg.Database.Port) + "/" + cfg.Database.DbName + "?sslmode=" + cfg.Database.Sslmode
}

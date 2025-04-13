package logger

import (
	"fmt"
	"invacc-backend/internal/config"
	"log/slog"
	"os"
)

// Init initializes the logger with the specified configuration.
func Init(cfg *config.Config) error {
	var logLevel slog.Level

	switch cfg.Logger.Level {
	case "debug":
		logLevel = slog.LevelDebug
	case "info":
		logLevel = slog.LevelInfo
	case "warn":
		logLevel = slog.LevelWarn
	case "error":
		logLevel = slog.LevelError
	default:
		return fmt.Errorf("invalid log level: %s", cfg.Logger.Level)
	}

	opts := &slog.HandlerOptions{Level: logLevel}

	if cfg.Logger.Output == "stdout" {
		slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, opts)))
	} else if cfg.Logger.Output == "file" {
		file, err := os.OpenFile("server.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
		if err != nil {
			return fmt.Errorf("failed to open log file: %w", err)
		}
		slog.SetDefault(slog.New(slog.NewJSONHandler(file, opts)))
	} else {
		return fmt.Errorf("invalid log output: %s", cfg.Logger.Output)
	}

	return nil
}

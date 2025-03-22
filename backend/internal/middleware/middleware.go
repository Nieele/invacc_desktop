package middleware

import (
	"context"
	"net/http"

	"invacc-backend/internal/service"
)

type contextKey string

const UserCtxKey contextKey = "userID"

func JWTAuthMiddleware(authService service.AuthService) func(next http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

			cookie, err := r.Cookie("token")
			if err != nil || cookie.Value == "" {
				http.Error(w, "unauthorized: token missing", http.StatusUnauthorized)
				return
			}

			userID, err := authService.Authentication(cookie.Value)
			if err != nil {
				http.Error(w, "unauthorized: invalid token", http.StatusUnauthorized)
				return
			}

			ctx := context.WithValue(r.Context(), UserCtxKey, userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

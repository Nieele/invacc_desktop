// internal/handlers/utils.go
package handlers

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"

	"invacc-backend/internal/apierrors"
)

// Structs for API-Errors
type ErrorObject struct {
	Status string      `json:"status"`
	Code   string      `json:"code"`
	Title  string      `json:"title"`
	Detail string      `json:"detail"`
	Meta   interface{} `json:"meta,omitempty"`
}
type ErrorResponse struct{ Errors []ErrorObject }

// Writing JSON responses
func writeJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(payload)
}

// Writing API errors
func writeError(w http.ResponseWriter, err error) {
	w.Header().Set("Content-Type", "application/vnd.api+json")
	var apiErr apierrors.Error
	if errors.As(err, &apiErr) {
		status := apiErr.Status()
		obj := ErrorObject{
			Status: strconv.Itoa(status),
			Code:   apiErr.Code(),
			Title:  http.StatusText(status),
			Detail: apiErr.Error(),
			Meta:   apiErr.Details(),
		}
		w.WriteHeader(status)
		json.NewEncoder(w).Encode(ErrorResponse{[]ErrorObject{obj}})
		return
	}
	// fallback 500
	w.WriteHeader(http.StatusInternalServerError)
	json.NewEncoder(w).Encode(ErrorResponse{[]ErrorObject{{
		Status: "500", Code: "internal_server_error", Title: "Internal Server Error", Detail: "unexpected error",
	}}})
}

// internal/apierrors/apierrors.go
package apierrors

import "fmt"

type Error interface {
	error
	Status() int
	Code() string
	Details() interface{}
}

type apiErr struct {
	status  int
	code    string
	message string
	details interface{}
}

func (e *apiErr) Error() string        { return e.message }
func (e *apiErr) Status() int          { return e.status }
func (e *apiErr) Code() string         { return e.code }
func (e *apiErr) Details() interface{} { return e.details }

// NewBadRequestError 400
func NewBadRequestError(code, message string, details interface{}) Error {
	return &apiErr{400, code, message, details}
}

// NewNotFoundError 404
func NewNotFoundError(code, message string) Error {
	return &apiErr{404, code, message, nil}
}

// NewInternalError 500
func NewInternalError(err error) Error {
	return &apiErr{500, "internal_server_error", fmt.Sprintf("internal error: %v", err), nil}
}

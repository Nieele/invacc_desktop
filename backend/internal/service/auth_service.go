package service

import (
	"errors"
	"time"

	"invacc-backend/internal/models"
	"invacc-backend/internal/repository"

	"github.com/golang-jwt/jwt/v4"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

var ErrInvalidCredentials = errors.New("invalid credentials")

type AuthService interface {
	SignJwtToken(login string, expirationTime time.Time) (string, error)

	Registration(login, password string) error

	Authorization(creds models.Credentials) (string, error)
	Authentication(token string) error
}

type authService struct {
	authRepo     repository.AuthRepository
	jwtSecretKey []byte
}

func NewAuthService(db *gorm.DB, jwtSecretKey []byte) AuthService {
	repo := repository.NewAuthRepository(db)
	return &authService{authRepo: repo, jwtSecretKey: jwtSecretKey}
}

func (s *authService) SignJwtToken(login string, expirationTime time.Time) (string, error) {
	claims := jwt.RegisteredClaims{
		Subject:   login,
		ExpiresAt: jwt.NewNumericDate(expirationTime),
		IssuedAt:  jwt.NewNumericDate(time.Now()),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(s.jwtSecretKey)

	return tokenString, err
}

func (s *authService) Registration(login, password string) error {
	hashPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	err = s.authRepo.InsertCustomer(login, string(hashPassword))
	return err
}

func (s *authService) Authorization(creds models.Credentials) (string, error) {
	storedHashPassword, err := s.authRepo.GetCustomerPassword(creds.Login)

	if err != nil {
		return "", err
	}

	err = bcrypt.CompareHashAndPassword([]byte(storedHashPassword), []byte(creds.Password))
	if err != nil {
		return "", err
	}

	token, err := s.SignJwtToken(creds.Login, time.Now().Add(24*time.Hour))

	return token, err
}

func (s *authService) Authentication(jwtToken string) error {
	claims := &jwt.RegisteredClaims{}
	token, err := jwt.ParseWithClaims(jwtToken, claims, func(token *jwt.Token) (interface{}, error) {
		return s.jwtSecretKey, nil
	})
	if err != nil || !token.Valid {
		return errors.New("invalid token")
	}

	return nil
}

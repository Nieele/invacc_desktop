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

type AuthService interface {
	SignJwtToken(login string, expirationTime time.Time) (string, error)

	Register(creds models.CustomerAuth) error
	Login(creds models.CustomerAuth) (string, error)

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

func (s *authService) Register(creds models.CustomerAuth) error {
	hashPassword, err := bcrypt.GenerateFromPassword([]byte(creds.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	err = s.authRepo.InsertCustomer(creds.Login, string(hashPassword))
	return err
}

func (s *authService) Login(creds models.CustomerAuth) (jwt string, err error) {
	storedAuth, err := s.authRepo.GetCustomerAuth(creds.Login)

	if err != nil {
		return "", err
	}

	err = bcrypt.CompareHashAndPassword([]byte(storedAuth.Password), []byte(creds.Password))
	if err != nil {
		return "", err
	}

	// clear password for security reasons
	storedAuth.Password = ""

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

package service

import (
	"errors"
	"fmt"
	"time"

	"invacc-backend/internal/config"
	"invacc-backend/internal/models"
	"invacc-backend/internal/repository"

	"github.com/golang-jwt/jwt/v4"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

var (
	ErrInvalidToken       = errors.New("invalid token")
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrInvalidInput       = errors.New("invalid input")
)

type AuthService interface {
	Register(creds models.CustomerAuth) error
	Login(creds models.CustomerAuth) (string, error)
	Authentication(token string) (user_id uint, err error)
}

type AuthClaimsJWT struct {
	jwt.RegisteredClaims
	UserID uint `json:"user_id"`
}

type authService struct {
	authRepo repository.AuthRepository
	config   config.Auth
}

func NewAuthService(db *gorm.DB, config config.Auth) AuthService {
	return &authService{
		authRepo: repository.NewAuthRepository(db),
		config:   config,
	}
}

func (s *authService) signJwtToken(userID uint, expirationTime time.Time) (string, error) {
	claims := AuthClaimsJWT{
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
		UserID: userID,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenStr, err := token.SignedString(s.config.JWTSecretKey)
	if err != nil {
		return "", fmt.Errorf("couldn't sign token user_id %d: %w", userID, err)
	}

	return tokenStr, nil
}

// TDOO: add validation github.com/go-playground/validator/v10
func (s *authService) validateCredentials(creds models.CustomerAuth) error {
	if creds.Login == "" || creds.Password == "" {
		return ErrInvalidInput
	}
	return nil
}

func (s *authService) Register(creds models.CustomerAuth) error {
	if err := s.validateCredentials(creds); err != nil {
		return err
	}

	hashPassword, err := bcrypt.GenerateFromPassword([]byte(creds.Password), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("couldn't hash password: %w", err)
	}

	return s.authRepo.InsertCustomer(creds.Login, string(hashPassword))
}

func (s *authService) Login(creds models.CustomerAuth) (string, error) {
	if err := s.validateCredentials(creds); err != nil {
		return "", err
	}

	storedAuth, err := s.authRepo.GetCustomerAuth(creds.Login)
	if err != nil {
		return "", err
	}

	if err := bcrypt.CompareHashAndPassword([]byte(storedAuth.Password), []byte(creds.Password)); err != nil {
		return "", fmt.Errorf("couldn't compare hashed passwords: %w", err)
	}

	expirationTime := time.Now().Add(s.config.TokenExpiry)
	return s.signJwtToken(storedAuth.ID, expirationTime)
}

func (s *authService) Authentication(jwtToken string) (uint, error) {
	claims := &AuthClaimsJWT{}
	token, err := jwt.ParseWithClaims(jwtToken, claims, func(token *jwt.Token) (interface{}, error) {
		return s.config.JWTSecretKey, nil
	})

	if err != nil || !token.Valid {
		return 0, ErrInvalidToken
	}

	return claims.UserID, nil
}

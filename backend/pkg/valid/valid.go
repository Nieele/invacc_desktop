package valid

import "github.com/go-playground/validator/v10"

var validate *validator.Validate

func Init() {
	validate = validator.New()
}

func ValidateEmail(email string) error {
	return validate.Var(email, "required,email")
}

func ValidatePassword(password string) error {
	return validate.Var(password, "required,min=8")
}

func ValidatePhone(phone string) error {
	return validate.Var(phone, "required,len=10")
}

func ValidatePassport(passport string) error {
	return validate.Var(passport, "required,len=10")
}

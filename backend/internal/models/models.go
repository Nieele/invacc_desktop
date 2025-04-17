package models

type ItemWithWarehouseName struct {
	Item
	WarehouseName string `json:"warehouse_name"`
}

// CustomersAuth in db
type CustomerAuth struct {
	ID       uint   `gorm:"primaryKey" json:"id"`
	Email    string `gorm:"type:varchar(50);not null;unique" json:"email"`
	Password string `gorm:"type:varchar(60);not null" json:"password"`
}

func (CustomerAuth) TableName() string {
	return "customersauth"
}

// CustomersInfo in db
type CustomerInfo struct {
	ID                uint   `gorm:"column:id;primaryKey;autoIncrement" json:"id"`
	FirstName         string `gorm:"column:firstname;type:varchar(50);not null" json:"firstname"`
	LastName          string `gorm:"column:lastname;type:varchar(50);not null" json:"lastname"`
	Phone             string `gorm:"column:phone;type:varchar(30);not null;unique" json:"phone"`
	Passport          string `gorm:"column:passport;type:varchar(30);not null;default:'empty'" json:"passport"`
	Phone_verified    bool   `gorm:"column:phone_verified;type:boolean;not null;default:false" json:"phone_verified"`
	Email_verified    bool   `gorm:"column:email_verified;type:boolean;not null;default:false" json:"email_verified"`
	Passport_verified bool   `gorm:"column:passport_verified;type:boolean;not null;default:false" json:"passport_verified"`
}

func (CustomerInfo) TableName() string {
	return "customersinfo"
}

type CustomersInfoWithEmail struct {
	CustomerInfo
	Email string `json:"email"`
}

type Cart struct {
	ID         uint `gorm:"primaryKey" json:"id"`
	CustomerID uint `gorm:"not null;column:customer_id" json:"customer_id"`
	ItemID     uint `gorm:"not null;column:item_id" json:"item_id"`
}

func (Cart) TableName() string {
	return "cart"
}

// not in db
type MultiRent struct {
	CustomerID   uint   `json:"customer_id"`
	ItemsID      []uint `json:"items_id"`
	Address      string `json:"address"`
	NumberOfDays uint   `json:"number_of_days"`
}

// not in db
type MultiRentWithoutCustomerID struct {
	ItemsID      []uint `json:"items_id"`
	Address      string `json:"address"`
	NumberOfDays uint   `json:"number_of_days"`
}

// not in db
type CustomerAuthRegistration struct {
	Login     string `json:"login"`
	Password  string `json:"password"`
	FirstName string `json:"firstname"`
	LastName  string `json:"lastname"`
	Email     string `json:"email"`
	Phone     string `json:"phone"`
	Passport  string `json:"passport"`
}

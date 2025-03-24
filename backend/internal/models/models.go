package models

import (
	"gorm.io/datatypes"
)

// Items in db
type Item struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	WarehouseID     int            `gorm:"not null;column:warehouse_id" json:"warehouse_id"`
	Name            string         `gorm:"type:varchar(50);not null" json:"name"`
	Description     *string        `gorm:"type:text" json:"description,omitempty"`
	ExtraAttributes datatypes.JSON `gorm:"type:jsonb" json:"extra_attributes,omitempty"`
	Quality         int            `gorm:"not null;default:100" json:"quality"`
	Price           float64        `gorm:"type:decimal(10,2);not null" json:"price"`
	LatePenalty     float64        `gorm:"type:decimal(10,2);not null" json:"late_penalty"`
	Active          bool           `gorm:"not null;default:true" json:"active"`
	Img_url         string         `gorm:"type:text;not null" json:"img_url"`
}

func (Item) TableName() string {
	return "items"
}

type ItemWithWarehouseName struct {
	Item
	WarehouseName string `json:"warehouse_name"`
}

// CustomersAuth in db
type CustomerAuth struct {
	ID       uint   `gorm:"primaryKey" json:"id"`
	Login    string `gorm:"type:varchar(50);not null;unique" json:"login"`
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
	Phone_verified    bool   `gorm:"column:phone_verified;type:boolean;not null;default:false" json:"phone_verified"`
	Email             string `gorm:"column:email;type:varchar(50);not null;default:'empty'" json:"email"`
	Email_verified    bool   `gorm:"column:email_verified;type:boolean;not null;default:false" json:"email_verified"`
	Passport          string `gorm:"column:passport;type:varchar(30);not null;default:'empty'" json:"passport"`
	Passport_verified bool   `gorm:"column:passport_verified;type:boolean;not null;default:false" json:"passport_verified"`
}

func (CustomerInfo) TableName() string {
	return "customersinfo"
}

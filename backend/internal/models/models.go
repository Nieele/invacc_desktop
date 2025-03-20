package models

import (
	"gorm.io/datatypes"
)

// not in db. for login
type Credentials struct {
	Login    string `json:"login"`
	Password string `json:"password"`
}

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
}

// CustomersAuth in db
type CustomerAuth struct {
	ID       uint   `gorm:"primaryKey" json:"id"`
	Login    string `gorm:"type:varchar(50);not null;unique" json:"login"`
	Password string `gorm:"type:varchar(60);not null" json:"password"`
}

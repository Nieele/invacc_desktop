// internal/models/rent.go
package models

import "time"

type Rent struct {
	ID               uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	ItemID           uint           `gorm:"not null;unique" json:"item_id"`
	Item             Item           `gorm:"foreignKey:ItemID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT;" json:"item"`
	CustomerID       uint           `gorm:"not null" json:"customer_id"`
	CustomerInfo     CustomerInfo   `gorm:"foreignKey:CustomerID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT;" json:"customer"`
	PromocodeID      *uint          `json:"promocode_id,omitempty"`
	Promocode        *Promocode     `gorm:"foreignKey:PromocodeID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT;" json:"promocode,omitempty"`
	Address          string         `gorm:"type:varchar(255);not null" json:"address"`
	DeliveryStatusID uint           `gorm:"not null;default:2" json:"delivery_status_id"`
	DeliveryStatus   DeliveryStatus `gorm:"foreignKey:DeliveryStatusID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT;" json:"delivery_status"`
	NumberOfDays     int            `gorm:"not null" json:"number_of_days"`
	StartRentTime    *time.Time     `gorm:"type:timestamp" json:"start_rent_time,omitempty"`
	EndRentTime      *time.Time     `gorm:"type:timestamp" json:"end_rent_time,omitempty"`
	TotalPayments    *float64       `gorm:"type:decimal(10,2)" json:"total_payments,omitempty"`
	Overdue          bool           `gorm:"not null;default:false" json:"overdue"`
}

func (Rent) TableName() string {
	return "rent"
}

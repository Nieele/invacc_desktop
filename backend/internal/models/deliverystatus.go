// internal/models/deliverystatus.go
package models

type DeliveryStatus struct {
	ID          uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	StatusCode  string `gorm:"type:text;not null;unique" json:"status_code"`
	Description string `gorm:"type:text;not null" json:"description"`
}

func (DeliveryStatus) TableName() string {
	return "deliverystatus"
}

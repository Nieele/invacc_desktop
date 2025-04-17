// internal/models/warehouse.go
package models

type Warehouse struct {
	ID      uint   `gorm:"primaryKey" json:"id"`
	Name    string `gorm:"type:varchar(50);not null;unique" json:"name"`
	Phone   string `gorm:"type:varchar(15);not null;unique" json:"phone"`
	Email   string `gorm:"type:varchar(50);not null;unique" json:"email"`
	Address string `gorm:"type:varchar(100);not null;unique" json:"address"`
	Active  bool   `gorm:"not null;default:true" json:"active"`
}

func (Warehouse) TableName() string { return "warehouses" }

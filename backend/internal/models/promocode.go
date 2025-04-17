// internal/models/promocode.go
package models

import "time"

type Promocode struct {
	ID           uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Code         string    `gorm:"type:varchar(50);not null;unique" json:"code"`
	Description  *string   `gorm:"type:text" json:"description,omitempty"`
	Percent      int       `gorm:"not null;check:percent>0 AND percent<100" json:"percent"`
	StartDate    time.Time `gorm:"type:date;not null;default:CURRENT_DATE;check:start_date>=CURRENT_DATE" json:"start_date"`
	EndDate      time.Time `gorm:"type:date;not null;check:end_date>CURRENT_DATE" json:"end_date"`
	NumberOfUses int       `gorm:"not null;default:0" json:"number_of_uses"`
}

func (Promocode) TableName() string {
	return "promocodes"
}

// internal/models/category.go
package models

type Category struct {
	ID           uint   `gorm:"primaryKey" json:"id"`
	CategoryName string `gorm:"type:varchar(50);not null;column:category_name" json:"category_name"`
}

func (Category) TableName() string { return "categories" }

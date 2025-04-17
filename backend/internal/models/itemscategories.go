// internal/models/itemscategories.go
package models

type ItemsCategories struct {
	ItemID     uint `gorm:"column:item_id"`
	CategoryID uint `gorm:"column:category_id"`
}

func (ItemsCategories) TableName() string { return "itemscategories" }

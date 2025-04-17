// internal/models/item.go
package models

import "gorm.io/datatypes"

type Item struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	WarehouseID     uint           `gorm:"not null;column:warehouse_id" json:"warehouse_id"`
	Warehouse       Warehouse      `gorm:"foreignKey:WarehouseID;references:ID" json:"warehouse"`
	Name            string         `gorm:"type:varchar(50);not null" json:"name"`
	Description     *string        `gorm:"type:text" json:"description,omitempty"`
	ExtraAttributes datatypes.JSON `gorm:"type:jsonb" json:"extra_attributes,omitempty"`
	Quality         int            `gorm:"not null;default:100" json:"quality"`
	Price           float64        `gorm:"type:decimal(10,2);not null" json:"price"`
	LatePenalty     float64        `gorm:"type:decimal(10,2);not null" json:"late_penalty"`
	Deposit         float64        `gorm:"type:decimal(10,2);not null" json:"deposit"`
	Active          bool           `gorm:"not null;default:true" json:"active"`
	ImgURL          *string        `gorm:"type:text;column:img_url" json:"img_url,omitempty"`

	Categories []Category `gorm:"many2many:itemscategories;joinForeignKey:ItemID;joinReferences:CategoryID" json:"categories"`
}

func (Item) TableName() string { return "items" }

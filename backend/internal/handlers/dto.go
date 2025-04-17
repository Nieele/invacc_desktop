package handlers

// ItemDTO represents a simplified item for list responses.
// swagger:model
// example:
//
//	id: 1
//	name: "Hammer"
//	price: 12.50
//	warehouse_name: "Main Depot"
//	categories: ["Tools", "Hardware"]
type ItemDTO struct {
	ID            uint     `json:"id"`
	Name          string   `json:"name"`
	Price         float64  `json:"price"`
	WarehouseName string   `json:"warehouse_name"`
	Categories    []string `json:"categories"`
}

// CategoryDTO represents a category in item details.
// swagger:model
// example:
//
//	id: 2
//	category_name: "Hardware"
type CategoryDTO struct {
	ID           uint   `json:"id"`
	CategoryName string `json:"category_name"`
}

// WarehouseDTO represents warehouse data in item details.
// swagger:model
// example:
//
//	id: 1
//	name: "Main Depot"
//	phone: "+123456789"
//	email: "depot@example.com"
//	address: "123 Warehouse St."
//	active: true
type WarehouseDTO struct {
	ID      uint   `json:"id"`
	Name    string `json:"name"`
	Phone   string `json:"phone"`
	Email   string `json:"email"`
	Address string `json:"address"`
	Active  bool   `json:"active"`
}

// ItemDetailDTO represents full item details in a single response.
// swagger:model
// example:
//
//	id: 1
//	name: "Hammer"
//	description: "Steel hammer"
//	extra_attributes: {"weight": "1kg", "color": "red"}
//	quality: 100
//	price: 12.50
//	late_penalty: 1.00
//	deposit: 5.00
//	active: true
//	img_url: "http://..."
//	warehouse:
//	  $ref: "#/definitions/WarehouseDTO"
//	categories:
//	  - $ref: "#/definitions/CategoryDTO"
type ItemDetailDTO struct {
	ID              uint                   `json:"id"`
	Name            string                 `json:"name"`
	Description     *string                `json:"description,omitempty"`
	ExtraAttributes map[string]interface{} `json:"extra_attributes"`
	Quality         int                    `json:"quality"`
	Price           float64                `json:"price"`
	LatePenalty     float64                `json:"late_penalty"`
	Deposit         float64                `json:"deposit"`
	Active          bool                   `json:"active"`
	ImgURL          *string                `json:"img_url,omitempty"`
	Warehouse       WarehouseDTO           `json:"warehouse"`
	Categories      []CategoryDTO          `json:"categories"`
}

// PageMeta contains pagination metadata.
// swagger:model
// example:
//
//	page: 1
//	limit: 10
//	total: 53
type PageMeta struct {
	Page  int   `json:"page"`
	Limit int   `json:"limit"`
	Total int64 `json:"total"`
}

// PaginatedResponse describes a paginated list response.
// swagger:model
// example:
//
//	data:
//	  - $ref: "#/definitions/ItemDTO"
//	meta:
//	  $ref: "#/definitions/PageMeta"
//	links:
//	  self: "items?page=1&limit=10"
//	  prev: ""
//	  next: "items?page=2&limit=10"
type PaginatedResponse struct {
	Data  []ItemDTO         `json:"data"`
	Meta  PageMeta          `json:"meta"`
	Links map[string]string `json:"links"`
}

// ItemDetailResponse describes a single‑item payload.
// swagger:response ItemDetailResponse
type ItemDetailResponse struct {
	// in: body
	Data ItemDetailDTO `json:"data"`
}

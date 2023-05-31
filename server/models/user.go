package models

type User struct {
	UserID string `json:"user_id"`
	Username string `json:"username"`
	Image string `json:"image"`
	Email string `json:"email"`
	Password string `json:"password"`
	IsSeller bool `json:"is_seller"`
}
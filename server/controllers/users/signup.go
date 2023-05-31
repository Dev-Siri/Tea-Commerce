package user_controllers

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"tea-commerce/db"
	"tea-commerce/models"
	"tea-commerce/utils"

	"github.com/dgrijalva/jwt-go"
	"golang.org/x/crypto/bcrypt"
)

func Signup(w http.ResponseWriter, r *http.Request) {
	body, bodyReadError := io.ReadAll(r.Body)

	if bodyReadError != nil {
		http.Error(w, "Failed to read user credentials.", http.StatusBadRequest)
		return
	}

	user := models.User{
		UserID: utils.GenerateID(),
	}

	if jsonParseError := json.Unmarshal(body, &user); jsonParseError != nil {
		http.Error(w, "Failed to parse body as JSON.", http.StatusInternalServerError)
		return
	}

	if user.Username == "" || !utils.IsValidEmail(user.Email) || user.Password == "" {
		http.Error(w, "Username/Password fields are either empty or Email is not valid.", http.StatusBadRequest)
		return
	}

	hashedPassword, passwordHashError := bcrypt.GenerateFromPassword([]byte(user.Password), 10)

	if passwordHashError != nil {
		http.Error(w, "Failed to hash your password.", http.StatusInternalServerError)
		return
	}

	user.Password = string(hashedPassword)

	imageName := utils.GenerateID()
	filepath := fmt.Sprintf("users/%s", imageName)
	imageUrl, imageUploadError := db.UploadDataURL(user.Image, filepath)

	if imageUploadError != nil {
		http.Error(w, "Failed to upload your profile picture.", http.StatusInternalServerError)
		return
	}

	user.Image = imageUrl

	_, dbQueryError := db.SQL().Query(`
		INSERT INTO Users(user_id, username, image, email, password)
		VALUES (
			$1, $2, $3, $4, $5
		)
	;`, user.UserID, user.Username, user.Image, user.Email, user.Password)

	if dbQueryError != nil {
		http.Error(w, "Failed to create your account.", http.StatusInternalServerError)
		fmt.Println(dbQueryError)
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.UserID,
		"username": user.Username,
		"image": user.Image,
		"email": user.Email,
		"is_seller": user.IsSeller,
	})

	secretKey := []byte(os.Getenv("JWT_SECRET"))
	authToken, tokenSignError := token.SignedString(secretKey)

	if tokenSignError != nil {
		http.Error(w, "Failed to sign your authentication token.", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprintf(w, "%s", authToken)
}
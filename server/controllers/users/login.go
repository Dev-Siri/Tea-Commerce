package user_controllers

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"tea-commerce/db"
	"tea-commerce/models"

	"github.com/dgrijalva/jwt-go"
	"golang.org/x/crypto/bcrypt"
)

func Login(w http.ResponseWriter, r *http.Request) {
	body, bodyReadError := io.ReadAll(r.Body)

	if bodyReadError != nil {
		http.Error(w, "Failed to read user credentials.", http.StatusBadRequest)
		return
	}

	var user models.User

	if jsonParseError := json.Unmarshal(body, &user); jsonParseError != nil {
		http.Error(w, "Failed to parse body as JSON.", http.StatusInternalServerError)
		return
	}

	rows, dbError := db.SQL().Query(`
		SELECT * FROM Users
		WHERE email = $1
		LIMIT 1
		;`, user.Email)

	if dbError != nil {
		http.Error(w, "Failed to get your info.", http.StatusInternalServerError)
	}

	defer rows.Close()

	var dbUser models.User

	if rows.Next() {		
		if scanError := rows.Scan(
			&dbUser.UserID,
			&dbUser.Username,
			&dbUser.Email,
			&dbUser.Password,
			&dbUser.IsSeller,
			&dbUser.Image,
		); scanError != nil {
			http.Error(w, "Failed to scan user data.", http.StatusInternalServerError)
			fmt.Printf("%v", scanError)
			return
		}
	} else {
		http.Error(w, "User with the given email was not found.", http.StatusNotFound)
		return
	}
	
	if noMatchError := bcrypt.CompareHashAndPassword([]byte(dbUser.Password), []byte(user.Password)); noMatchError != nil {
		http.Error(w, "Password is incorrect", http.StatusBadRequest)
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": dbUser.UserID,
		"username": dbUser.Username,
		"image": dbUser.Image,
		"email": dbUser.Email,
		"is_seller": dbUser.IsSeller,
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
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	error_handlers "tea-commerce/controllers/errors"

	"tea-commerce/db"
	"tea-commerce/routes"

	"github.com/joho/godotenv"
)

func main() {
	if dotenvLoadError := godotenv.Load(); dotenvLoadError != nil {
		log.Printf("Failed to load .env")
		return
	}

	port := os.Getenv("PORT")

	if port == "" {
		port = "5000"
	}

	addr := fmt.Sprintf(":%s", port)

  fmt.Printf("Server running on %s\n", addr)

	connectionString := os.Getenv("NEON_POSTGRES_CONNECTION_URL")

	if connectionString == "" {
		log.Printf("Connection string not found.")
		return
	}

	if dbConnectError := db.Connect(connectionString); dbConnectError != nil {
		log.Printf("%v", dbConnectError)
		return
	}

	if firebaseInitError := db.FirebaseInit(); firebaseInitError != nil {
		log.Printf("%v", firebaseInitError)
		return
	}

	go http.HandleFunc("/", error_handlers.NotFound)

	go routes.RegisterProductRoutes()
	go routes.RegisterUserRoutes()

	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Printf("%v", err)
	}
}

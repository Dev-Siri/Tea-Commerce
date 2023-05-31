package db

import (
	"database/sql"

	_ "github.com/lib/pq"
)

var database *sql.DB

func Connect(connectionString string) error {
	db, err := sql.Open("postgres", connectionString)

	if err != nil {
		return err
	}

	database = db

	return nil
}

func SQL() *sql.DB {
	return database
}
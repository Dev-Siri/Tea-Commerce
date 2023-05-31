package routes

import (
	"net/http"
	error_handlers "tea-commerce/controllers/errors"
	user_controllers "tea-commerce/controllers/users"
)

func RegisterUserRoutes() {
  go http.HandleFunc("/users/login", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodPost {
			user_controllers.Login(w, r)
		} else {
			error_handlers.MethodNotAllowed(w, r)
		}
	})

	go http.HandleFunc("/users/signup", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodPost {
			user_controllers.Signup(w, r)
		} else {
			error_handlers.MethodNotAllowed(w, r)
		}
	})
}

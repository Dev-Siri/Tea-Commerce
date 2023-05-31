package routes

import (
	"net/http"
	error_handlers "tea-commerce/controllers/errors"
	product_controllers "tea-commerce/controllers/products"
)

func RegisterProductRoutes() {
	go http.HandleFunc("/products", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			product_controllers.GetProducts(w, r)
		} else {
			error_handlers.MethodNotAllowed(w, r)
		}
	})
}
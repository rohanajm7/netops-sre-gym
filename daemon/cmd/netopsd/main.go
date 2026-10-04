// Command netopsd is the sandbox daemon: it builds isolated networks, runs
// commands inside them, injects faults and verifies fixes.
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

const version = "0.0.0-dev"

func newMux() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"status":  "ok",
			"impl":    "netopsd",
			"version": version,
		})
	})
	return mux
}

func main() {
	addr := os.Getenv("NETOPSD_ADDR")
	if addr == "" {
		addr = ":8700"
	}
	log.Printf("netopsd %s listening on %s", version, addr)
	log.Fatal(http.ListenAndServe(addr, newMux()))
}

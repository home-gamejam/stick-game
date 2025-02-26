package main

import (
	"crypto/tls"
	_ "embed"
	"log"
	"net/http"
	"os"
	"path/filepath"
)

//go:embed certs/local.emeraldwalk.com.crt
var certFile []byte

//go:embed certs/local.emeraldwalk.com.key
var keyFile []byte

func main() {
	// Get the directory of the executable
	exePath, err := os.Executable()
	if err != nil {
		log.Fatal(err)
	}
	exeDir := filepath.Dir(exePath)

	// Change the working directory to the directory of the executable
	err = os.Chdir(exeDir)
	if err != nil {
		log.Fatal(err)
	}

	// Directory to serve files from
	fs := http.FileServer(http.Dir("./web"))

	// Handler to serve files
	http.Handle("/", fs)

	// Load embedded certificates
	cert, err := tls.X509KeyPair(certFile, keyFile)
	if err != nil {
		log.Fatal(err)
	}

	// Create a TLS config with the embedded certificates
	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{cert},
	}

	// Start HTTPS server with the TLS config
	server := &http.Server{
		Addr:      ":8080",
		TLSConfig: tlsConfig,
	}

	// Start HTTPS server
	log.Println("Server listening on https://localhost:8080")
	err = server.ListenAndServeTLS("", "")
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

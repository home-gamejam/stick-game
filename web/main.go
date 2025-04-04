package main

import (
	_ "embed"
	"log"
	"net/http"
	"os"
	"path/filepath"
)

const (
	isHttps    = true
	publicDir  = "./web"
	serverAddr = ":8080"
)

// Gets passed in at build time via -ldflags
var hostName string

func main() {
	if hostName == "" {
		log.Fatal("certName is empty")
	}

	certFileName := hostName + ".crt"
	keyFileName := hostName + ".key"

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
	fs := http.FileServer(http.Dir(publicDir))

	// Handler to serve files
	http.Handle("/", fs)

	// Start HTTPS server
	if isHttps {
		log.Println("Server listening on https://" + hostName + serverAddr)
		err = http.ListenAndServeTLS(serverAddr, certFileName, keyFileName, nil)
	} else {
		log.Println("Server listening on http://" + hostName + serverAddr)
		err = http.ListenAndServe(serverAddr, nil)
	}

	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

package main

import (
	_ "embed"
	"flag"
	"log"
	"net/http"
	"path/filepath"
	"strings"
)

const (
	isHttps    = true
	publicDir  = "./web"
	serverAddr = ":8080"
)

// Gets passed in at build time via -ldflags
var hostName string

func main() {
	// Set a default value for hostName from ldflags and allow runtime override
	flag.StringVar(&hostName, "host", hostName, "Hostname for the server")
	flag.Parse()

	if hostName == "" {
		log.Fatal("certName is empty")
	}

	certFileName := hostName + ".crt"
	keyFileName := hostName + ".key"

	// Directory to serve files from
	fs := http.FileServer(http.Dir(publicDir))

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// http.FileServer usually 301 redirects index.html to / . This causes
		// issues with service workers, so serve the file directly.
		// See https://github.com/golang/go/issues/53870
		if strings.HasSuffix(r.URL.Path, "index.html") {
			// Serve the file directly without redirecting
			filePath := filepath.Join(publicDir, r.URL.Path)
			log.Println("Serving file:", filePath)

			// Open the file
			file, err := http.Dir(publicDir).Open("index.html")
			if err != nil {
				http.Error(w, "File not found", http.StatusNotFound)
				return
			}
			defer file.Close()

			// Get file info for ServeContent
			fileInfo, err := file.Stat()
			if err != nil {
				http.Error(w, "File not found", http.StatusNotFound)
				return
			}

			// Serve the file using ServeContent
			http.ServeContent(w, r, "index.html", fileInfo.ModTime(), file)

			return
		}

		// Serve the file
		fs.ServeHTTP(w, r)
	})

	// Handler to serve files
	http.Handle("/", handler)

	var err error

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

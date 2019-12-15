package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	name, _ := os.Hostname()

	http.HandleFunc("/webhook", func(w http.ResponseWriter, r *http.Request) {
		body, err := ioutil.ReadAll(r.Body)

		if err != nil {
			panic(err)
		}

		if r.Header.Get("Content-Type") == "application/json" {
			var indentedJSON bytes.Buffer
			json.Indent(&indentedJSON, body, "", " ")
			log.Println(indentedJSON.String())
		} else {
			log.Println(string(body))
		}

		fmt.Fprintf(w, "Alert received")
	})

	log.Printf("Server running at http://%s:8081\n", name)

	if err := http.ListenAndServe(":8081", nil); err != nil {
		log.Fatal(err)
	}
}

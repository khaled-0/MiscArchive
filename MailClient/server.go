package main

import (
	"html/template"
	"log"
	"net/http"
	"net/smtp"
	"os"
)

func main() {
	form := template.Must(template.ParseFiles("form.html"))

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		form.Execute(w, nil)
	})

	http.HandleFunc("/send", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Redirect(w, r, "/", http.StatusSeeOther)
			return
		}

		recipient := r.FormValue("recipient")
		subject := r.FormValue("subject")
		body := r.FormValue("body")

		from := os.Getenv("SMTP_EMAIL")
		pass := os.Getenv("SMTP_PASSWORD")

		if from == "" || pass == "" {
			form.Execute(w, map[string]any{
				"Error":     "SMTP credentials not set",
				"Recipient": recipient,
				"Subject":   subject,
				"Body":      body,
			})
			return
		}

		// SMTP Specs
		msg := "From: " + from + "\n" +
			"To: " + recipient + "\n" +
			"Subject: " + subject + "\n\n" +
			body

		auth := smtp.PlainAuth("", from, pass, "smtp.gmail.com")

		err := smtp.SendMail("smtp.gmail.com:587", auth, from, []string{recipient}, []byte(msg))
		if err != nil {
			form.Execute(w, map[string]any{
				"Error":     err.Error(),
				"Recipient": recipient,
				"Subject":   subject,
				"Body":      body,
			})
			return
		}

		form.Execute(w, map[string]any{
			"Message": "Email Has been delivered. No need to call the sender to let him know",
		})

	})

	log.Println("Server running on :8080")
	http.ListenAndServe(":8080", nil)
}

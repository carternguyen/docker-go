package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/labstack/echo/v4"
)

type Response struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Data    any    `json:"data"`
}

func main() {
	arg := flag.String("arg", "", "Display version and exit")
	flag.Parse()
	fmt.Println(*arg)

	e := echo.New()
	e.GET("/ping", func(c echo.Context) error {
		r := &Response{
			Code:    200,
			Message: "success",
			Data:    "Pong Server",
		}
		return c.JSON(http.StatusOK, r)
	})
	address := ":8080"
	apiServer := &http.Server{
		Addr: address,
		// ErrorLog:     NoLogger,
		ReadTimeout:  5 * time.Minute,
		WriteTimeout: 5 * time.Minute,
	}
	e.HideBanner = true
	e.Logger.SetOutput(NewNullWriter())
	fmt.Println("server listening on", address)
	_ = e.StartServer(apiServer)
}

type NullWriter struct{}

func NewNullWriter() *NullWriter {
	return &NullWriter{}
}

func (b *NullWriter) Write(p []byte) (int, error) {
	return len(p), nil
}

var NoLogger = log.New(NewNullWriter(), "", 0)

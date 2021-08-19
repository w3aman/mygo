package main

import (
	"fmt"

	"rsc.io/quote"

	"github.com/w3aman/mygo/greetings"
)

func main() {
	fmt.Println("Welcome, on board")

	fmt.Println(quote.Go())

	fmt.Println(greetings.Hello("Aman"))
}

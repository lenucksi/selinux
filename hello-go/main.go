package main

import (
	"flag"
	"fmt"
	"os"
)

const version = "1.0.0"

func main() {
	showVersion := flag.Bool("version", false, "show version")
	flag.Parse()

	if *showVersion {
		fmt.Fprintf(os.Stdout, "hello-go version %s\n", version)
		os.Exit(0)
	}

	fmt.Fprintln(os.Stdout, "Hello from the signed Arch repo!")
}

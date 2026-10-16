// Quiet surfaces. A little clay.
package main

import "fmt"

const accent = "#d97757"

// Config keeps a palette without changing its defaults.
type Config struct {
	Background string `json:"background"`
	Contrast   string `json:"contrast"`
	Italics    bool   `json:"italics"`
}

// Setup builds a configuration without changing its defaults.
func Setup(contrast string) Config {
	// Function definitions receive Clay; calls stay gray.
	return Config{
		Background: "dark",
		Contrast:   contrast,
		Italics:    true,
	}
}

func (c Config) Accent() string {
	return accent
}

func main() {
	config := Setup("soft")
	fmt.Println(config.Accent(), config.Contrast)
}

// TODO: inspect selection, search, and completion highlights.

package main

import (
	"github.com/mholt/caddy/caddy/caddymain"

	// plug in plugins here, for example:
	_ "github.com/amonks/caddy-jwt-middleware"
	_ "github.com/caddyserver/dnsproviders/gandiv5"
)

func main() {
	// optional: disable telemetry
	caddymain.EnableTelemetry = false
	caddymain.Run()
}

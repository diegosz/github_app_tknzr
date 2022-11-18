package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/bradleyfalzon/ghinstallation"
)

var (
	app     = "github_app_tknzr"
	version = "dev"
	commit  = "none"
	date    = "unknown"
)

func main() {
	appID := flag.Int64("app-id", 0, "App ID")
	instID := flag.Int64("inst-id", 0, "Installation ID")
	export := flag.Bool("export", false, "show token as 'export GITHUB_TOKEN=...'")
	showVersion := flag.Bool("version", false, "show version info")

	origUsage := flag.Usage
	flag.Usage = func() {
		origUsage()
		fmt.Fprintf(os.Stderr, "\n")
		fmt.Fprintf(os.Stderr, "== Build Info ==\n")
		versionInfo()
	}

	flag.Parse()

	// See https://github.com/golang/go/issues/37533
	// Decided to implement -version flag to return 0
	if *showVersion {
		versionInfo()
		os.Exit(0)
	}

	if *appID == 0 || *instID == 0 {
		fmt.Fprintf(os.Stderr, "App ID and Installation ID are required.\n\n")
		flag.Usage()
		os.Exit(1)
	}

	key := os.Getenv("GITHUB_PRIV_KEY")
	if key == "" {
		log.Fatal("Please populate GITHUB_PRIV_KEY environment variable with the private key for the App")
	}

	// Wrap the shared transport for use with the app ID authenticating with installation ID.
	itr, err := ghinstallation.New(http.DefaultTransport, *appID, *instID, []byte(key))
	if err != nil {
		log.Fatal(err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), time.Minute)
	defer cancel()

	token, err := itr.Token(ctx)
	if err != nil {
		log.Fatalf("Unable to get github token: %s", err)
	}

	if *export {
		showExport(token)
	} else {
		fmt.Println(token)
	}
}

func showExport(token string) {
	fmt.Printf("export GITHUB_TOKEN=%s\n", token)
}

func versionInfo() {
	fmt.Fprintf(os.Stderr, "%s Version: %s Commit: %s BuiltAt: %s\n", app, version, commit, date)
}

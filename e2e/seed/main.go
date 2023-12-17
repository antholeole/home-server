package main

import (
	"fmt"
	"os"

	"github.com/mkideal/cli"
)

type argT struct {
	cli.Helper

	Type   string `cli:"*t,type" usage:"The seed type. Can only be 'test' for now."`
	Action string `cli:"*a,action" usage:"Can either be 'setup' or 'teardown'."`
}

func main() {
	os.Exit(cli.Run(new(argT), func(ctx *cli.Context) error {
		argv := ctx.Argv().(*argT)

		if argv.Action == "setup" && argv.Type == "test" {
			SeedForTests()
		} else {
			return fmt.Errorf("unknown action and test combo '%s' '%s'", argv.Action, argv.Type)
		}

		return nil
	}))

}

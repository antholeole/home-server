package main

import (
	"e2e/seed/cmd"
	"fmt"
	"os"

	"github.com/mkideal/cli"
)

type argT struct {
	cli.Helper

	Action string `cli:"*a,action" usage:"nuke, setup-test"`
}

func main() {
	os.Exit(cli.Run(new(argT), func(ctx *cli.Context) error {
		argv := ctx.Argv().(*argT)

		var err error
		if argv.Action == "setup-test" {
			_, err = cmd.MkTestEnv()
		} else if argv.Action == "nuke" {
			err = cmd.Nuke()
		} else {
			err = fmt.Errorf("unknown action '%s'", argv.Action)
		}

		if err != nil {
			return err
		} else {
			fmt.Println("Done!")
			return nil
		}
	}))

}

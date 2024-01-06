package cmd

import (
	"e2e"
	pt "e2e/permission_tests"
)

func Nuke() error {
	adminClient := pt.AdminClient()
	_, err := e2e.DeleteAll(adminClient)

	return err
}

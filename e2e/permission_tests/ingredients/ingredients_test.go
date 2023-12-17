package permission_tests

import (
	"e2e"
	pt "e2e/permission_tests"
	"testing"

	"github.com/facebookgo/ensure"
)

func TestIngredients(t *testing.T) {
	uId, err := pt.InsertUser(nil)
	ensure.Nil(t, err)

	_, err = e2e.InsertIngredient(pt.AdminClient(), *uId, "hamburger")
	ensure.Nil(t, err)

	ensure.Nil(t, pt.CleanupUser(*uId))
}

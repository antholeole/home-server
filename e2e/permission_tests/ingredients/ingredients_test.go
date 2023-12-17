package permission_tests

import (
	"e2e"
	pt "e2e/permission_tests"
	"testing"

	"github.com/facebookgo/ensure"
	"github.com/google/uuid"
)

func TestIngredients(t *testing.T) {
	userAA := pt.UuidOrFail(t)
	userAB := pt.UuidOrFail(t)

	groupA, err := e2e.InsertGroup(pt.AdminClient())
	ensure.Nil(t, err)
	_, err = e2e.InsertUserWithGroup(pt.AdminClient(), userAA, groupA.Insert_group_one.Id)
	ensure.Nil(t, err)
	_, err = e2e.InsertUserWithGroup(pt.AdminClient(), userAB, groupA.Insert_group_one.Id)
	ensure.Nil(t, err)

	defer e2e.CleanupUsers(pt.AdminClient(), []uuid.UUID{
		userAA,
		userAB,
	}, []uuid.UUID{
		groupA.Insert_group_one.Id,
	})
}

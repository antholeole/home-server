package recipes

import (
	"e2e"
	seed "e2e/seed/cmd"
	"fmt"
	"testing"

	pt "e2e/permission_tests"

	"github.com/facebookgo/ensure"
)

func TestUserCantQueryOtherGroups(t *testing.T) {
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	res, err := e2e.QueryUser(env.GroupA.Friend.Client, env.GroupB.Friend.Uid)
	ensure.Nil(t, err)
	ensure.True(t, pt.IsDefaultUuid(res.User_by_pk.Id))
}

func TestUserCanQueryWithinGroup(t *testing.T) {
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	fmt.Println(pt.DebugGetJwt(t, env.GroupA.Friend.Uid))
	fmt.Println(env.GroupA.Owner.Uid.String())
	res, err := e2e.QueryUser(env.GroupA.Friend.Client, env.GroupA.Owner.Uid)
	ensure.Nil(t, err)
	ensure.DeepEqual(t, res.User_by_pk.Id, env.GroupA.Owner.Uid)
}

func TestUserCanEditOwnName(t *testing.T) {
	newName := "ralph"
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	res, err := e2e.UpdateFirstName(env.GroupA.Friend.Client, env.GroupA.Friend.Uid, newName)
	ensure.Nil(t, err)
	ensure.DeepEqual(t, res.Update_user.Returning[0].First_name, newName)
}

func TestUserCanRemoveThemselvesFromGroup(t *testing.T) {
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	res, err := e2e.RemoveUserFromGroup(env.GroupA.Friend.Client, env.GroupA.Friend.Uid, env.GroupA.Uid)
	ensure.Nil(t, err)
	ensure.DeepEqual(t, res.Delete_user_to_group.Affected_rows, 1)
}

func TestOwnerCanRemoveOtherFromGroup(t *testing.T) {
	t.Skip()
}

func TestOtherCantRemoveOtherFromGroup(t *testing.T) {
	t.Skip()
}

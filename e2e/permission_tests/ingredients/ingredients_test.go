package permission_tests

import (
	"e2e"
	seed "e2e/seed/cmd"
	"testing"

	pt "e2e/permission_tests"

	"github.com/facebookgo/ensure"
)

const ingredientName = "pickles"

func TestCantSeeOtherGroupIngredient(t *testing.T) {
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	groupAIngredient, err := e2e.InsertIngredient(env.GroupA.Friend.Client, &env.GroupA.Uid, ingredientName)
	defer e2e.DeleteIngredient(pt.AdminClient(), groupAIngredient.Insert_cooking_ingredients_one.Id)
	ensure.Nil(t, err)

	_, err = e2e.GetIngredient(env.GroupB.Owner.Client, groupAIngredient.Insert_cooking_ingredients_one.Id)
	ensure.NotNil(t, err)
}

func TestCanSeeNoUserIngredient(t *testing.T) {
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	adminIngredient, err := e2e.InsertIngredient(pt.AdminClient(), nil, ingredientName)
	defer e2e.DeleteIngredient(pt.AdminClient(), adminIngredient.Insert_cooking_ingredients_one.Id)
	ensure.Nil(t, err)

	_, err = e2e.GetIngredient(env.GroupB.Owner.Client, adminIngredient.Insert_cooking_ingredients_one.Id)
	ensure.Nil(t, err)
}

func TestCanSeeGroupmateIngredient(t *testing.T) {
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	groupAIngredient, err := e2e.InsertIngredient(env.GroupA.Friend.Client, &env.GroupA.Uid, ingredientName)
	defer e2e.DeleteIngredient(pt.AdminClient(), groupAIngredient.Insert_cooking_ingredients_one.Id)
	ensure.Nil(t, err)

	_, err = e2e.GetIngredient(env.GroupA.Owner.Client, groupAIngredient.Insert_cooking_ingredients_one.Id)
	ensure.NotNil(t, err)
}

func TestCantDeleteOtherGroupIngredient(t *testing.T) {
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	groupAIngredient, err := e2e.InsertIngredient(env.GroupA.Friend.Client, &env.GroupA.Uid, ingredientName)
	defer e2e.DeleteIngredient(pt.AdminClient(), groupAIngredient.Insert_cooking_ingredients_one.Id)
	ensure.Nil(t, err)

	_, err = e2e.DeleteIngredient(env.GroupB.Owner.Client, groupAIngredient.Insert_cooking_ingredients_one.Id)
	ensure.Nil(t, err)
}

func TestCanDeleteGroupIngredient(t *testing.T) {
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	groupAIngredient, err := e2e.InsertIngredient(env.GroupA.Owner.Client, &env.GroupA.Uid, ingredientName)
	defer e2e.DeleteIngredient(pt.AdminClient(), groupAIngredient.Insert_cooking_ingredients_one.Id)
	ensure.Nil(t, err)

	_, err = e2e.DeleteIngredient(env.GroupA.Friend.Client, groupAIngredient.Insert_cooking_ingredients_one.Id)
	ensure.Nil(t, err)
}

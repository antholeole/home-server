package recipes

import (
	"e2e"
	seed "e2e/seed/cmd"
	"testing"

	pt "e2e/permission_tests"

	"github.com/facebookgo/ensure"
)

func TestQueryOtherGroupRecipeDenied(t *testing.T) {
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	groupARecipe, err := e2e.InsertMockRecipe(env.GroupA.Friend.Client, env.GroupA.Uid)
	defer e2e.DeleteRecipe(pt.AdminClient(), groupARecipe.Insert_cooking_recipe_one.Id)
	ensure.Nil(t, err)

	deniedIngredient, err := e2e.GetIngredient(env.GroupB.Owner.Client, groupARecipe.Insert_cooking_recipe_one.Ingredients[0].Id)
	ensure.Nil(t, err)
	ensure.True(t, pt.IsDefaultUuid(deniedIngredient.Cooking_ingredients_by_pk.Id))

	deniedRecipe, err := e2e.GetRecipe(env.GroupB.Owner.Client, groupARecipe.Insert_cooking_recipe_one.Id)
	ensure.Nil(t, err)
	ensure.True(t, pt.IsDefaultUuid(deniedRecipe.Cooking_recipe_by_pk.Id))
}

func TestQuerySelfGroupRecipeAllowed(t *testing.T) {
	env, err := seed.MkTestEnv()
	ensure.Nil(t, err)
	defer env.Cleanup(t)

	groupARecipe, err := e2e.InsertMockRecipe(env.GroupA.Friend.Client, env.GroupA.Uid)
	defer e2e.DeleteRecipe(pt.AdminClient(), groupARecipe.Insert_cooking_recipe_one.Id)
	ensure.Nil(t, err)

	allowedIngredient, err := e2e.GetIngredient(env.GroupA.Owner.Client, groupARecipe.Insert_cooking_recipe_one.Ingredients[0].Id)
	ensure.Nil(t, err)
	ensure.DeepEqual(t, allowedIngredient.Cooking_ingredients_by_pk.Id, groupARecipe.Insert_cooking_recipe_one.Ingredients[0].Id)

	allowedRecipe, err := e2e.GetRecipe(env.GroupA.Friend.Client, groupARecipe.Insert_cooking_recipe_one.Id)
	ensure.Nil(t, err)
	ensure.DeepEqual(t, allowedRecipe.Cooking_recipe_by_pk.Id, groupARecipe.Insert_cooking_recipe_one.Id)
}

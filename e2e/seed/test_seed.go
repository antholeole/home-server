package main

import (
	"e2e"

	pt "e2e/permission_tests"

	"github.com/google/uuid"
)

type User struct {
	Id uuid.UUID
}

type Group struct {
	Id    uuid.UUID
	Users []User
}

type SeedData struct {
	MultipleUserGroup Group
	SingleUserGroup   Group
}

const (
	testUserMultipleFirstNameA = "TEST_USER_SEED_MULTIPLE_A"
	testUserMultipleFirstNameB = "TEST_USER_SEED_MULTIPLE_B"
	testUserSingleFirstNameA   = "TEST_USER_SEED_SINGLE_A"
)

func SeedForTests() error {
	userAA, err := pt.NewUuid()
	if err != nil {
		return err
	}
	userAB, err := pt.NewUuid()
	if err != nil {
		return err
	}
	userBA, err := pt.NewUuid()
	if err != nil {
		return err
	}

	groupMultiple, err := e2e.InsertGroup(pt.AdminClient())
	if err != nil {
		return err
	}

	groupSingle, err := e2e.InsertGroup(pt.AdminClient())
	if err != nil {
		return err
	}

	_, err = e2e.InsertUser(pt.AdminClient(), *userAA, testUserMultipleFirstNameA)
	if err != nil {
		return err
	}
	_, err = e2e.AddUserToGroup(pt.AdminClient(), *userAA, groupMultiple.Insert_group_one.Id)
	if err != nil {
		return err
	}

	_, err = e2e.InsertUser(pt.AdminClient(), *userAB, testUserMultipleFirstNameB)
	if err != nil {
		return err
	}
	_, err = e2e.AddUserToGroup(pt.AdminClient(), *userAB, groupMultiple.Insert_group_one.Id)
	if err != nil {
		return err
	}

	_, err = e2e.InsertUser(pt.AdminClient(), *userBA, testUserSingleFirstNameA)
	if err != nil {
		return err
	}
	_, err = e2e.AddUserToGroup(pt.AdminClient(), *userBA, groupSingle.Insert_group_one.Id)
	if err != nil {
		return err
	}

	return nil
}

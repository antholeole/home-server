package main

import (
	"e2e"
	pt "e2e/permission_tests"

	"github.com/Khan/genqlient/graphql"
	"github.com/facebookgo/stackerr"

	"github.com/google/uuid"
)

type User struct {
	Uid    uuid.UUID
	Client graphql.Client
}

type Group struct {
	Uid    uuid.UUID
	Owner  User
	Friend User
}

type TestEnv struct {
	GroupA Group
	GroupB Group

	Cleanup func() error
}

func MkTestEnv() (*TestEnv, error) {
	groupAOwner, err := pt.NewUuid()
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	groupAFriend, err := pt.NewUuid()
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	groupBOwner, err := pt.NewUuid()
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	groupBFriend, err := pt.NewUuid()
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	adminClient := pt.AdminClient()

	_, err = e2e.InsertUser(adminClient, *groupAOwner, "GroupAOwner")
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	_, err = e2e.InsertUser(adminClient, *groupBOwner, "GroupBOwner")
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	groupA, err := e2e.InsertGroup(adminClient, *groupAOwner)
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	groupAId := groupA.Insert_group_one.Id

	groupB, err := e2e.InsertGroup(adminClient, *groupBOwner)
	if err != nil {
		return nil, stackerr.Wrap(err)
	}
	groupBId := groupB.Insert_group_one.Id

	_, err = e2e.InsertUser(adminClient, *groupAFriend, "GroupAFriend")
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	_, err = e2e.InsertUser(adminClient, *groupBFriend, "GroupBFriend")
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	_, err = e2e.AddUserToGroup(adminClient, *groupAFriend, groupAId)
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	_, err = e2e.AddUserToGroup(adminClient, *groupBFriend, groupBId)
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	aOwnClient, err := pt.UserClient(*groupAOwner)
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	aFriendClient, err := pt.UserClient(*groupAFriend)
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	bOwnerClient, err := pt.UserClient(*groupBOwner)
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	bFriendClient, err := pt.UserClient(*groupBFriend)
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	return &TestEnv{
		GroupA: Group{
			Uid: groupAId,
			Owner: User{
				Uid:    *groupAOwner,
				Client: aOwnClient,
			},
			Friend: User{
				Uid:    *groupAFriend,
				Client: aFriendClient,
			},
		},
		GroupB: Group{
			Uid: groupBId,
			Owner: User{
				Uid:    *groupBOwner,
				Client: bOwnerClient,
			},
			Friend: User{
				Uid:    *groupBFriend,
				Client: bFriendClient,
			},
		},
		Cleanup: func() error {
			_, err = e2e.Cleanup(
				adminClient,
				[]uuid.UUID{*groupAOwner, *groupAFriend, *groupBOwner, *groupBFriend},
				[]uuid.UUID{groupAId, groupBId},
			)

			return err
		},
	}, nil
}

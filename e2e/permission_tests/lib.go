package permission_tests

import (
	"context"
	"e2e"
	"fmt"
	"net/http"
	"os"

	"github.com/Khan/genqlient/graphql"
	"github.com/google/uuid"
)

func NewUuid() (*uuid.UUID, error) {
	id, err := uuid.NewV7()

	return &id, err
}

type hasuraAdminTransport struct {
	secret  string
	wrapped http.RoundTripper
}

func (t *hasuraAdminTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	req.Header.Set("x-hasura-admin-secret", t.secret)
	return t.wrapped.RoundTrip(req)
}

func Context() context.Context {
	return context.TODO()
}

func client(httpClient *http.Client) graphql.Client {
	hasuraPort := os.Getenv("HASURA_PORT")

	url := fmt.Sprintf("http://localhost:%s/v1/graphql", hasuraPort)

	return graphql.NewClient(url, httpClient)
}

func AdminClient() graphql.Client {
	hasuraAdminSecret := os.Getenv("HASURA_ADMIN_SECRET")

	return client(&http.Client{
		Transport: &hasuraAdminTransport{
			secret:  hasuraAdminSecret,
			wrapped: http.DefaultTransport,
		},
	})
}

func InsertUser(userId *uuid.UUID) (*uuid.UUID, error) {
	uId := userId
	if uId == nil {
		madeUid, err := NewUuid()
		if err != nil {
			return nil, err
		}
		uId = madeUid
	}

	res, err := e2e.InsertUser(Context(), AdminClient(), *uId)
	if err != nil {
		return nil, err
	}

	ret := res.GetInsert_user_one().User_id
	return &ret, nil
}

func CleanupUser(userId uuid.UUID) error {
	_, err := e2e.CleanupUser(Context(), AdminClient(), userId)
	return err
}

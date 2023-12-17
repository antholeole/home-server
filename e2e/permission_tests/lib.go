package permission_tests

import (
	"e2e"
	"fmt"
	"net/http"
	"os"
	"testing"

	"github.com/Khan/genqlient/graphql"
	"github.com/facebookgo/ensure"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

func NewUuid() (*uuid.UUID, error) {
	id, err := uuid.NewV7()

	return &id, err
}

func client(httpClient *http.Client) graphql.Client {
	hasuraPort := os.Getenv("HASURA_PORT")

	url := fmt.Sprintf("http://localhost:%s/v1/graphql", hasuraPort)

	return graphql.NewClient(url, httpClient)
}

type hasuraAdminTransport struct {
	secret  string
	wrapped http.RoundTripper
}

func (t *hasuraAdminTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	req.Header.Set("x-hasura-admin-secret", t.secret)
	return t.wrapped.RoundTrip(req)
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

type hasuraJwtClient struct {
	jwt     string
	wrapped http.RoundTripper
}

func (h *hasuraJwtClient) RoundTrip(req *http.Request) (*http.Response, error) {
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", h.jwt))
	return h.wrapped.RoundTrip(req)
}

func UserClient(t *testing.T, userId uuid.UUID) graphql.Client {
	jwt, err := mintJwt(userId)
	ensure.Nil(t, err)

	return client(&http.Client{
		Transport: &hasuraJwtClient{
			jwt:     jwt,
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

	res, err := e2e.InsertUser(AdminClient(), *uId)
	if err != nil {
		return nil, err
	}

	ret := res.GetInsert_user_one().User_id
	return &ret, nil
}

func CleanupUser(userId uuid.UUID) error {
	_, err := e2e.CleanupUser(AdminClient(), userId)
	return err
}

func mintJwt(userId uuid.UUID) (string, error) {
	jwtSecret := os.Getenv("jwtSecret")
	newJwt := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"https://hasura.io/jwt/claims": map[string]string{
			"x-hasura-default-role": "user",
			"X-hasura-user-id":      userId.String(),
		},
	})

	mintedJwt, err := newJwt.SignedString(jwtSecret)
	if err != nil {
		return "", err
	}

	return mintedJwt, nil
}

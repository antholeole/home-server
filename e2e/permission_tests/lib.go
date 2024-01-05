package permission_tests

import (
	"fmt"
	"net/http"
	"os"
	"testing"

	"github.com/Khan/genqlient/graphql"
	"github.com/facebookgo/ensure"
	"github.com/facebookgo/stackerr"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

func UuidOrFail(t *testing.T) uuid.UUID {
	id, err := uuid.NewV7()
	ensure.Nil(t, err)
	return id
}

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

func UserClientOrFail(t *testing.T, userId uuid.UUID) graphql.Client {
	client, err := UserClient(userId)
	ensure.Nil(t, err)
	return client
}

func UserClient(userId uuid.UUID) (graphql.Client, error) {
	jwt, err := mintJwt(userId)
	if err != nil {
		return nil, stackerr.Wrap(err)
	}

	return client(&http.Client{
		Transport: &hasuraJwtClient{
			jwt:     jwt,
			wrapped: http.DefaultTransport,
		},
	}), nil
}

func mintJwt(userId uuid.UUID) (string, error) {
	jwtSecret := os.Getenv("JWT_SECRET")
	newJwt := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"https://hasura.io/jwt/claims": map[string]string{
			"x-hasura-default-role": "user",
			"X-hasura-user-id":      userId.String(),
		},
	})

	mintedJwt, err := newJwt.SignedString([]byte(jwtSecret))
	if err != nil {
		return "", stackerr.Wrap(err)
	}

	return mintedJwt, nil
}

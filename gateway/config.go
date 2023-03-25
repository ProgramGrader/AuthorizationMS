package gateway

import (
	"context"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

type Config struct {
	CERBOS_API_URL string
	BUCKET_URL     string
	BUCKET_PREFIX  string
}

func (c *Config) Build(ctx context.Context) (*Config, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, err
	}
	ssmClient := ssm.NewFromConfig(cfg)
	c.CERBOS_API_URL, err = getParameter(ctx, ssmClient, "csgrader-CERBOS_API_URL")
	c.BUCKET_URL, err = getParameter(ctx, ssmClient, "csgrader-BUCKET_URL")
	c.BUCKET_PREFIX, err = getParameter(ctx, ssmClient, "csgrader-BUCKET_PREFIX")

	if err != nil {
		return nil, err
	}
	return c, nil
}

func getParameter(ctx context.Context, ssmClient *ssm.Client, parameterName string) (string, error) {
	t := true
	input := &ssm.GetParameterInput{
		Name:           &parameterName,
		WithDecryption: &t,
	}
	resp, err := ssmClient.GetParameter(ctx, input)
	if err != nil {
		return "", err
	}
	return *resp.Parameter.Value, nil
}

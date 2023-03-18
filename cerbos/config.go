package cerbos

import (
	"context"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

type Config struct {
	API_URL string
}

func (c *Config) Build(ctx context.Context) (*Config, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, err
	}
	ssmClient := ssm.NewFromConfig(cfg)
	c.API_URL, err = getParameter(ctx, ssmClient, "csgrader-CERBOS_URL")
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

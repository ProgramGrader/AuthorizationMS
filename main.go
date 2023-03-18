// Copyright 2021 Zenauth Ltd.
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/cerbos/cerbos-aws-lambda/cerbos"
	"net/http"
	"time"
)

const cerbosHTTPAddr = "http://127.0.0.1:3592"

// basic skeleton for the redirect

// Handler testing to see if this lambda implementation really works

func Handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	// logging
	fmt.Printf("event.HTTPMethod %v\n", request.HTTPMethod)
	fmt.Printf("event.Body %v\n", request.Body)
	fmt.Printf("event.QueryStringParameters %v\n", request.QueryStringParameters)
	fmt.Printf("event %v\n", request)

	httpClient := http.Client{Timeout: time.Duration(1) * time.Second}
	//httpListenAddr := ":3592"
	//localCerbosURL := "http://127.0.0.1" + httpListenAddr + "/_cerbos/health"
	c := &cerbos.Config{}
	config, err := c.Build(ctx)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
			Body:       "CONFIGURATION WAS NOT LOADED PROPERLY: CAN'T FIND API URL",
		}, err
	}
	remoteCerbosUrl := config.API_URL
	cerbosClient := cerbos.NewLauncher(&httpClient, remoteCerbosUrl)

	err = cerbosClient.StartProcess(ctx, "cerbos", "", "config.yml")
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusBadGateway,
			Body:       "ERROR INITIALIZING CERBOS CLIENT",
		}, err
	}

	err = cerbosClient.StopProcess()
	if err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	// placeholder
	body := request.Body

	// the rest of the error codes are to be handled in terraform, specifically through aws_api_integration_response
	return events.APIGatewayProxyResponse{
		Body: body,
		//302: found, 301: moved permanently, 300: multiple location available.
		StatusCode: 302, //
		Headers: map[string]string{
			"Content-Type":                 "application/json",
			"Access-Control":               "Content-Type",
			"Access-Control-Allow-Origin":  "*",
			"Access-Control-Allow-Methods": "GET",
		},
	}, nil
}

func main() {
	lambda.Start(Handler)
}

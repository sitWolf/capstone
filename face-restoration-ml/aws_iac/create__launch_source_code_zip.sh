#! /bin/bash

# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-cli-package.html
aws cloudformation package \
  --template s3launchtemplate.json \
  --s3-bucket reconstructionlambdafunctioncode \
  --use-json
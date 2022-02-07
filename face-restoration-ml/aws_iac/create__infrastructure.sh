#! /bin/bash

aws cloudformation create-stack \
--region $1 \
--stack-name $2 \
--template-body file://create__infrastructure.yml \
--parameters file://parameters__infrastructure.json

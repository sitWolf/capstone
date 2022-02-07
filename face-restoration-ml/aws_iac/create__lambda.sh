#! /bin/bash

aws cloudformation create-stack \
--region eu-west-2 \
--stack-name udacitycapstonserverless \
--template-body file://create__lambda.yml \
--capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
--parameters \
ParameterKey=SecurityGroupIDs,ParameterValue='sg-0adb469c147410a7f' \
ParameterKey=SubnetIDs,ParameterValue='subnet-091b109dd634e890c\,subnet-0c12c7392b77edbed\,subnet-069b201d5726d248d' \
ParameterKey=AccessPointARN,ParameterValue=arn:aws:elasticfilesystem:eu-west-2:683561334096:access-point/fsap-079795c58c099070a \
ParameterKey=S3InputBucketName,ParameterValue=reconstructioninbucket \
ParameterKey=S3OutputBucketName,ParameterValue=reconstructionoutbucket \
ParameterKey=S3SourceCodeBucketName,ParameterValue=reconstructionsourcebucket \
ParameterKey=S3SourceCodeKey,ParameterValue=5b32bb8a49b14ae69b007291e209a7fe

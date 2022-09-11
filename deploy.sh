#!/usr/bin/env bash
mule_version="4.4.0"
client_id=<client_id>
client_secret=<client_secret>
grant_type="client_credentials"
deployment_target=<deployment_target>
business_group_id=<business_group_id>
platformClientId=<platformClientId>
platformClientSecret=<platformClientSecret>
platformEnv="dev"
replicas=1
ingressUrl=<ingressUrl>
deploymentName=<deploymentName>
cpuReserved=500m
cpuLimit=500m
memReserved=1000Mi
memoryLimit=1000Mi
clustered=false
enforceReplicasAcrossNodes=false

### Retrieve Access token using Connected APP ClientId and ClientSecret
### Pre-requisite - Create a connected app in Anypoint platform access management which has all required permissions
### Anypoint host for EU -  eu1.anypoint.mulesoft.com 

API_RESPONSE=$(curl -s -X POST \
https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token \
-H "Content-Type: application/x-www-form-urlencoded" \
-d "client_id=$client_id&client_secret=$client_secret&grant_type=$grant_type")

ACCESS_TOKEN=$(echo $API_RESPONSE | sed -e 's/{"access_token":"\(.*\)","expires_in.*/\1/')

### can also be implemented using jq + curl
### access_token=$(curl -s -X POST \
### https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token \
### -H "Content-Type: application/x-www-form-urlencoded" \
### -d "client_id=$client_id&client_secret=$client_secret&grant_type=client_credentials" | jq -r '.access_token')

echo "Access Token: $ACCESS_TOKEN"

mvn clean package deploy -DmuleDeploy -Dmule.version=$mule_version -DauthToken=$ACCESS_TOKEN \
-Drtf.app.name=$rtf_app_name -Ddeployment.target=$deployment_target \
-Dbusiness.group.id=$business_group_id -DplatformClientId=$platformClientId \
-DplatformClientSecret=$platformClientSecret -DplatformEnv=$platformEnv -Dreplicas=$replicas \
-DingressUrl=$ingressUrl -DdeploymentName=$deploymentName

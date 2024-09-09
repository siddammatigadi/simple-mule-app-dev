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


### E.g.
image: maven:3.8.2-jdk-8

variables:
  authToken: 0
stages:
    - deploy_dev
    - deploy_sit
    - deploy_uat
    - deploy_prod

deploy_to_dev:
    stage: deploy_dev
    variables:
        ca_client_id: $eu_dev_ca_client_id
        ca_client_secret: $eu_dev_ca_client_secret
    before_script:
        - apt-get -qq update
        - apt-get install -y jq
    script:
        - touch /root/.m2/settings.xml
        - cat <<< "$EU1_MAVEN_SETTINGS_XML" >/root/.m2/settings.xml 
        - | 
            authToken=$(curl -H "Content-Type: application/json" -d "{\"client_id\":\"$eu_dev_ca_client_id\", \"client_secret\":\"$eu_dev_ca_client_secret\", \"grant_type\":\"client_credentials\"}" https://eu1.anypoint.mulesoft.com/accounts/api/v2/oauth2/token | jq -r .access_token)
        - mvn clean deploy -P dev -DskipTests=true -DmuleDeploy -DauthToken=${authToken} -Danypoint.environment=$eu_dev -Danypoint.businessgroup="XYZ\MuleSoftGlobal\EU" -Danypoint.workers=$eu_workers -Danypoint.workertype=$eu_workertype -Danypoint.region=$eu_region -Dencryption.key=$eu_sandbox_encryption_key -Dmule.env=dev -Danypoint.platform.client_id=$eu_dev_pl_client_id  -Danypoint.platform.client_secret=$eu_dev_pl_client_secret -Dorder.papi.username=$eu_nb_dev_orderpapi_username -Dorder.papi.password=$eu_nb_dev_orderpapi_password -Dbt.kafka.producer.basic.user=$eu_dev_kafkaproducer_username -Dbt.kafka.producer.basic.password=$eu_dev_kafkaproducer_password
    only:
        - develop
        - /^feature\/.*$/
        - /^hotfix\/.*$/
    environment: dev
    when: manual

deploy_to_sit:
    stage: deploy_sit
    variables:
        ca_client_id: $eu_sit_ca_client_id
        ca_client_secret: $eu_sit_ca_client_secret
    before_script:
        - apt-get -qq update
        - apt-get install -y jq
    script:
        - echo $GITLAB_USER_NAME
        - touch /root/.m2/settings.xml
        - cat <<< "$EU1_MAVEN_SETTINGS_XML" >/root/.m2/settings.xml 
        - | 
            authToken=$(curl -H "Content-Type: application/json" -d "{\"client_id\":\"$eu_sit_ca_client_id\", \"client_secret\":\"$eu_sit_ca_client_secret\", \"grant_type\":\"client_credentials\"}" https://eu1.anypoint.mulesoft.com/accounts/api/v2/oauth2/token | jq -r .access_token)
        - mvn clean deploy -P sit -DskipTests=true -DmuleDeploy -DauthToken=${authToken} -Danypoint.environment=$eu_sit -Danypoint.businessgroup="XYZ\MuleSoftGlobal\EU" -Danypoint.workers=$eu_workers -Danypoint.workertype=$eu_workertype -Danypoint.region=$eu_region -Dencryption.key=$eu_sandbox_encryption_key -Dmule.env=sit -Danypoint.platform.client_id=$eu_sit_pl_client_id  -Danypoint.platform.client_secret=$eu_sit_pl_client_secret -Dorder.papi.username=$eu_nb_sit_orderpapi_username -Dorder.papi.password=$eu_nb_sit_orderpapi_password -Dbt.kafka.producer.basic.user=$eu_sit_kafkaproducer_username -Dbt.kafka.producer.basic.password=$eu_sit_kafkaproducer_password
        
    only:
        - develop
    environment: sit
       
    when: manual

deploy_to_uat:
    stage: deploy_uat
    before_script:
        - apt-get -qq update
        - apt-get install -y jq
    script:
        - touch /root/.m2/settings.xml
        - cat <<< "$EU1_MAVEN_SETTINGS_XML" >/root/.m2/settings.xml 
        - | 
            authToken=$(curl -H "Content-Type: application/json" -d "{\"client_id\":\"$eu_uat_ca_client_id\", \"client_secret\":\"$eu_uat_ca_client_secret\", \"grant_type\":\"client_credentials\"}" https://eu1.anypoint.mulesoft.com/accounts/api/v2/oauth2/token | jq -r .access_token)
        - mvn clean deploy -P uat -DskipTests=true -DmuleDeploy -DauthToken=${authToken} -Danypoint.environment=$eu_uat -Danypoint.businessgroup="XYZ\MuleSoftGlobal\EU" -Danypoint.workers=$eu_uat_workers -Danypoint.workertype=$eu_workertype -Danypoint.region=$eu_region -Dencryption.key=$eu_sandbox_encryption_key -Dmule.env=uat -Danypoint.platform.client_id=$eu_uat_pl_client_id  -Danypoint.platform.client_secret=$eu_uat_pl_client_secret -Dorder.papi.username=$eu_nb_uat_orderpapi_username -Dorder.papi.password=$eu_nb_uat_orderpapi_password -Dbt.kafka.producer.basic.user=$eu_uat_kafkaproducer_username -Dbt.kafka.producer.basic.password=$eu_uat_kafkaproducer_password
        
    only:
        - release
    environment: uat
    when: manual

deploy_to_prod:
    stage: deploy_prod
    variables:
        ca_client_id: $eu_prod_ca_client_id
        ca_client_secret: $eu_prod_ca_client_secret
    before_script:
        - apt-get -qq update
        - apt-get install -y jq
    script:
        - touch /root/.m2/settings.xml
        - cat <<< "$EU1_MAVEN_SETTINGS_XML" >/root/.m2/settings.xml 
        - | 
            authToken=$(curl -H "Content-Type: application/json" -d "{\"client_id\":\"$eu_prod_ca_client_id\", \"client_secret\":\"$eu_prod_ca_client_secret\", \"grant_type\":\"client_credentials\"}" https://eu1.anypoint.mulesoft.com/accounts/api/v2/oauth2/token | jq -r .access_token)
        - mvn deploy -P prd -DskipTests=true -DmuleDeploy -DauthToken=${authToken} -Danypoint.environment=$eu_prod -Danypoint.businessgroup="XYZ\MuleSoftGlobal\EU" -Danypoint.workers=$eu_prod_workers -Danypoint.workertype=$eu_prod_workertype -Danypoint.region=$eu_region -Dencryption.key=$eu_prod_encryption_key -Dmule.env=prd -Danypoint.platform.client_id=$eu_prod_pl_client_id -Danypoint.platform.client_secret=$eu_prod_pl_client_secret -Dorder.papi.username=$eu_nb_prd_orderpapi_username -Dorder.papi.password=$eu_nb_prd_orderpapi_password -Dbt.kafka.producer.basic.user=$eu_prd_kafkaproducer_username -Dbt.kafka.producer.basic.password=$eu_prd_kafkaproducer_password 
        
    only:
        - master
    environment: prod
    when: manual


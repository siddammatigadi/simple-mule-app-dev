# simple-mule-app-dev
simple-mule-app-dev

# Automate RTF Deployment
Introduction This repo allows you automate application deployment into Runtime Fabric from Jenkins pipeline. This was created for a CICD tool that allowed ingestion of shell script and curl commands to automate build and deployment. It is tested on macOs.

# E.g.
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


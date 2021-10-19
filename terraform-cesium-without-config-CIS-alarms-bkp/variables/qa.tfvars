##Project Variables
region      = "eu-west-2"
environment = "qa"
project     = "cesium"
owner       = "noorul.hoda@trilateralresearch.com"
profile     = "cesium-tf-admin-qa"

##EC2/VPC Variables
myip          = "82.30.85.128/32"
instance-type = "t2.micro"

cidr          = "10.1.0.0/22"
priv-subnet   = ["10.1.0.0/25", "10.1.0.128/25", "10.1.1.0/25"]
pub-subnet    = ["10.1.1.128/25", "10.1.2.0/25", "10.1.2.128/25"]


##R53 Hosted Zone Domain Name Variable
website-domain-main = "qa.cesium.trilateral.ai"
ecs-domain-name     = "ecs.qa.cesium.trilateral.ai"
api-domain-name     = "api.qa.cesium.trilateral.ai"

##RDS Variables
db-username       = "cesiumqaadmin"
db-password       = "CesiumQa2021"
db_instance_class = "db.t2.medium"

##Lambda List
lambda_list = ["api"]

##Lambda List variable needed for API GW
lambda_for_api      = ["api"]
##

##Lambda List used for ML
ml_lambda_list = ["ActivateDatasetDevelopment", "ActivateModelTraining", "ActivateSaveModelResult", "ActivateUpdatePredictions"]

##ECS Fargate Variables
fargate-ecrname = "ecr"
cluster-name    = "cluster"
ecs-service     = "service"
taskdefinition  = "taskdefinition"

##ECS Fargate repository (BitBucket Repo)
ecs-repo_name = "CesiumAdmin/ecs-fargate" //In format "/<workspace-id>/<bitbucket-reponame>"

##Frontend/Backend Repo (BitBucket Repo)
repo_name = "CesiumAdmin/cesium" //In format "/<workspace-id>/<bitbucket-reponame>"

##ML Lambda Repo (BitBucket Repo)
ml_lambda_repo_name = "CesiumAdmin/ml-lambda" //In format "<workspace-id>/<bitbucket-reponame>"

##ECS ALB Whitelist IP List
##( Should be in cidr format as list separated by comma and each ip cidr in double quotes)
alb_whitelist_ipv4-list = [
  "93.70.156.138/32", #Aliai
  "81.2.158.47/32",  #Anita
  "78.105.233.43/32", #Ezra
  "109.255.54.28/32", #Mick
  "82.30.85.128/32",  #Noor
  "209.93.73.173/32", #Rob
  "78.149.170.210/32" #Sam
]
alb_whitelist_ipv6-list = []

##ALB WAFV2 (ECS) Blacklist IPs
##( Should be in cidr format as list separated by comma and each ip cidr in double quotes)
alb_blacklist_ipv4-list = []
alb_blacklist_ipv6-list = []

##Cloudfront WAFV2 White|Black List IPs
##( Should be in cidr format as list separated by comma and each ip cidr in double quotes)
cf_whitelist_ipv4-list = [
  "93.70.156.138/32", #Aliai
  "81.2.158.47/32",  #Anita
  "78.105.233.43/32", #Ezra
  "109.255.54.28/32", #Mick
  "82.30.85.128/32",  #Noor
  "209.93.73.173/32", #Rob
  "78.149.170.210/32", #Sam
  "5.252.220.36/32"    #Tri Office
]
cf_whitelist_ipv6-list = []
cf_blacklist_ipv4-list = []
cf_blacklist_ipv6-list = []

##On Prem GW IP, CIDR Block (Site to Site VPN)
cgw-onprem-ip          = "62.253.153.113"
onprem-cidr-block      = ["10.193.201.0/24"]

#lambda_list         = ["associatesNetworkLoad", "associatesNetworkGrow", "personProfile", "profileSearch","queryStatsCache","personTimeline","queryCompareCache","etl_getNicheID","etl_getData","etl_saveMaceData","etl_dynamoData","plotStats","api","etl_getMaceData"]

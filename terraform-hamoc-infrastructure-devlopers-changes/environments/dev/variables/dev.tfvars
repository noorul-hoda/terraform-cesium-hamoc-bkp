##Project Variables
region      = "eu-west-2"
environment = "dev"
project     = "hamoc"
owner       = "noorul.hoda@trilateralresearch.com"
profile     = "hamoc-tf-admin-dev"

##VPC Variables
cidr                   = "10.12.0.0/16"
priv-subnet            = ["10.12.0.0/24", "10.12.1.0/24", "10.12.2.0/24"]
pub-subnet             = ["10.12.3.0/24", "10.12.4.0/24", "10.12.5.0/24"]
single_nat_gateway     = true
bastion_allowed_range  = [
  "82.30.85.128/32"   #Noor
]

##RDS Variables
db-username       = "hamocdevadmin"
db-password       = "DevHamoc2021"
db_instance_class = "db.t2.medium"

##Neptune Variables
neptune_instance_class = "db.t3.medium"

##Elasticsearh Variables
es_instance_type       = "t3.small.elasticsearch"

##ECS Fargate Variables
fargate-ecrname = "ecr"
cluster-name    = "cluster"
ecs-service     = "service"
taskdefinition  = "taskdefinition"

##R53 Hosted Zone Domain Name Variable
website-domain-main = "dev.hamoc.trilateral.ai"
ecs-domain-name     = "ecs.dev.hamoc.trilateral.ai"
api-domain-name     = "api.dev.hamoc.trilateral.ai"

##ECS Fargate repository (BitBucket Repo)
ecs-repo_name = "hamoc/hamoc-ecs" //In format "<workspace-id>/<bitbucket-reponame>"

##Frontend/Backend Repo (BitBucket Repo)
repo_name = "hamoc/hamoc-frontend-backend" //In format "<workspace-id>/<bitbucket-reponame>"


##ECS ALB Whitelist IP List
##( Should be in cidr format as list separated by comma and each ip cidr in double quotes)
alb_whitelist_ipv4-list = [
  "82.30.85.128/32"  #Noor
]
alb_whitelist_ipv6-list = []

##ALB WAFV2 (ECS) Blacklist IPs 
##( Should be in cidr format as list separated by comma and each ip cidr in double quotes)
alb_blacklist_ipv4-list = []
alb_blacklist_ipv6-list = []

##Cloudfront WAFV2 White|Black List IPs
##( Should be in cidr format as list separated by comma and each ip cidr in double quotes)
cf_whitelist_ipv4-list = [
  "82.30.85.128/32",   #Noor
  "151.227.152.47/32", #Toby Office
  "5.252.220.36/32",   #Hamoc Office
  "86.41.87.180/32",   #Patrick
  "86.41.160.143/32",  #Dineshraj
  "90.89.184.244/32",  #Simon
  "86.152.38.129/32",  #Jojeena
  "92.105.152.197/32"  #Peter
]
cf_whitelist_ipv6-list = [
  "2a00:23c7:5806:8301:cd78:7bc5:609d:ad69/128"   #Hayley
]
cf_blacklist_ipv4-list = []
cf_blacklist_ipv6-list = []

##On Prem GW IP, CIDR Block (Site to Site VPN)
vpn_enabled            = false
cgw_onprem_ip          = ""
onprem_cidr_block      = []

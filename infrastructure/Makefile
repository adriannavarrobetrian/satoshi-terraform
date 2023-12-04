############################
#	    VARIABLES          #
############################
ENV = dev
TERRAFORM = $(shell terraform -v | sed -n 's/^Terraform v//p')
TERRAFORM_VERSION = 1.6.0
DETECTED_OS = $(shell uname -s)

############################
#		ENVIRONMENTS	   #
############################
dev: ENV = dev
staging: ENV = staging
prod: ENV = prod
############################
# 		TARGETS			   #
############################

# check-version:
# 	@if [ "${TERRAFORM}" < "${TERRAFORM_VERSION}" ] ; then \
#     	echo "You're not running required version of Terraform which is V${TERRAFORM_VERSION}"; \
#         exit 1; \
#     fi

#check-config:
#	@if [ -f ../env/${ENV}/private.tfvars ] ; then \
		echo "Found private.tfvars";\
	else \
		echo "Not found private.tfvars";\
	exit 1 ;\
	fi

#access_key =$(shell cat ../env/${ENV}/private.tfvars | grep access_key | awk '{print $$3}' | sed 's/\"//g')
#secret_key =$(shell cat ../env/${ENV}/private.tfvars | grep secret_key | awk '{print $$3}' | sed 's/\"//g')
#aws_region =$(shell cat ../env/${ENV}/variables.tfvars | grep aws_region | awk '{print $3}' | sed 's/\"//g')
aws_region = "eu-west-1"

init:
	@terraform init -reconfigure \
 			-var-file=../env/${ENV}/variables.tfvars \
 			-backend-config=bucket=satoshi-terraform-state-${ENV} \
 			-backend-config=key=${ENV}/terraform.tfstate \
			-backend-config=region=${aws_region} \
 			-backend=true 

plan:
	@terraform plan \
			-var-file=../env/${ENV}/variables.tfvars
apply:
	@terraform apply \
			-var-file=../env/${ENV}/variables.tfvars
			
	
#######################
#  TERRAFORM ACTIONS  #
#######################
dev: init plan apply 
staging: init plan apply
prod: init plan apply

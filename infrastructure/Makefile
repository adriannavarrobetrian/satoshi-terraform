############################
#		ENVIRONMENTS	   #
############################
dev: ENV = dev
staging: ENV = staging
prod: ENV = prod

dev-destroy: ENV = dev
staging-destroy: ENV = staging
prod-destroy: ENV = prod
############################
# 		TARGETS			   #
############################

init:
	@terraform init -reconfigure \
 			-var-file=../env/${ENV}/variables.tfvars \
 			-backend-config=bucket=satoshi-terraform-state-${ENV} \
 			-backend-config=key=${ENV}/terraform.tfstate \
			-backend-config=dynamodb_table="terraform_state" \
 			-backend=true 

plan:
	@terraform fmt && tflint && tfsec && terraform plan \
			-var-file=../env/${ENV}/variables.tfvars \
			-var-file=./variables.tfvars
apply:
	@terraform apply \
			-var-file=../env/${ENV}/variables.tfvars  \
			-var-file=./variables.tfvars
destroy:
	@terraform destroy \
			-var-file=../env/${ENV}/variables.tfvars  \
			-var-file=./variables.tfvars	

#######################
#  TERRAFORM ACTIONS  #
#######################
dev: init plan apply 
staging: init plan apply
prod: init plan apply

dev-destroy: init plan destroy
staging-destroy: init plan destroy
prod-destroy: init plan destroy
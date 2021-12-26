##################################################
#
# Set up terraform
# https://learn.hashicorp.com/tutorials/terraform/eks
#
##################################################
terraform {
  backend "s3" {
    bucket  = "terraform-poc-infrastructure"
    key     = "terraform/terraform.tfstate"
    region  = "us-east-1"
    profile = "makechange-dev"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

  required_version = ">= 0.14"
}

##################################################
#
# Add providers for provisioning infrastructure
#
##################################################
provider "aws" {
  region  = "us-east-1"
  profile = "makechange-dev"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
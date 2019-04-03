# Github Variables
variable "github_organization_name" {
  description = "Name of the GitHub organization"
}
variable "paid_github_member_1" {
  description = "First Paid Github Member"
}
variable "paid_github_member_2" {
  description = "Second Paid Github Member"
}
variable "paid_github_member_3" {
  description = "Third Paid Github Member"
}
variable "paid_github_member_4" {
  description = "Fourth Paid Github Member"
}
variable "paid_github_member_5" {
  description = "Fifth Paid Github Member"
}
variable "github_personal_access_token" {
  description = "Github Personal Access Token"
}
variable "slack_url" {
  description = "Slack Url for Github Webhooks"
}
variable "gitops_homepage_url" {
  description = "Github GitOps Homepage URL"
}

# Set the name of the Github Organization
provider "github" {
  token        = "${var.github_personal_access_token}"
  organization = "${var.github_organization_name}"
}

# Add a users to the organization
# Currently my member supports 5 invited seats.

resource "github_membership" "paid_github_membership_1" {
  username = "${var.paid_github_member_1}"
  role     = "admin"
}
resource "github_membership" "paid_github_membership_2" {
  username = "${var.paid_github_member_2}"
  role     = "member"
}
resource "github_membership" "paid_github_membership_3" {
  username = "${var.paid_github_member_3}"
  role     = "member"
}
# Unused seats
#resource "github_membership" "paid_github_membership_4" {
#  username = "${var.paid_github_member_4}"
#  role     = "member"
#}
#resource "github_membership" "paid_github_membership_5" {
#  username = "${var.paid_github_member_5}"
#  role     = "member"
#}

data "github_user" "paid_github_member_1" {
  username = "${var.paid_github_member_1}"
}
data "github_user" "paid_github_member_2" {
  username = "${var.paid_github_member_2}"
}
data "github_user" "paid_github_member_3" {
  username = "${var.paid_github_member_3}"
}
# Unused
#data "github_user" "paid_github_member_4" {
#  username = "${var.paid_github_member_4}"
#}
#data "github_user" "paid_github_member_5" {
#  username = "${var.paid_github_member_5}"
#}

# Create a Organization Team
resource "github_team" "gitops" {
  name        = "gitops-team"
  description = "Team for use with Terraform Gitops"
  privacy     = "closed"
}

# Create Keypair
resource "tls_private_key" "gitops-deploy-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "GitOps Deploy Key (Public Key): " {
  value = "${tls_private_key.gitops-deploy-key.public_key_openssh}"
}
output "GitOps Deploy Key (Private Key): " {
  value = "${tls_private_key.gitops-deploy-key.private_key_pem}"
}

# Team Membership

resource "github_team_membership" "gitops_team_membership_1" {
  team_id  = "${github_team.gitops.id}"
  username = "${var.paid_github_member_1}"
  role     = "maintainer"
}

resource "github_team_membership" "gitops_team_membership_2" {
  team_id  = "${github_team.gitops.id}"
  username = "${var.paid_github_member_2}"
  role     = "member"
}
resource "github_team_membership" "gitops_team_membership_3" {
  team_id  = "${github_team.gitops.id}"
  username = "${var.paid_github_member_3}"
  role     = "member"
}

# Create repository

resource "github_repository" "gitops" {
  name               = "gitops"
  description        = "Azure GitOPs"
  homepage_url       = "${var.gitops_homepage_url}"
  has_issues         = "true"
  has_projects       = "true"
  has_wiki           = "true"
  license_template   = "apache-2.0"
  gitignore_template = "Terraform"
}

# Assign team gitops to repo
resource "github_team_repository" "gitops_team_repo" {
  team_id    = "${github_team.gitops.id}"
  repository = "${github_repository.gitops.name}"
  permission = "push"
}

# Add a deploy key to gitops repository
resource "github_repository_deploy_key" "gitops_repo_deploy_key" {
  title = "gitops-repo-deploy-key"
  repository = "gitops"
  key = "${tls_private_key.gitops-deploy-key.public_key_openssh}"
  read_only = "false"
  depends_on = [
    "github_repository.gitops",
  ]
}

resource "github_repository_webhook" "gitops-slack" {
  events = [
    "*"
  ]
  name = "web"
  repository = "${github_repository.gitops.name}"
  configuration {
    url          = "${var.slack_url}"
    content_type = "json"
    insecure_ssl = false
  }
  depends_on = [
    "github_repository.gitops",
  ]
}

# Add hypervci as a collaborator
resource "github_repository_collaborator" "gitops_repo_collaborator_1" {
  repository = "${github_repository.gitops.name}"
  username = "${var.paid_github_member_1}"
  # Permission must, be pull push or admin
  permission = "admin"
  depends_on = [
    "github_repository.gitops",
  ]
}

resource "github_repository_collaborator" "gitops_repo_collaborator_2" {
  repository = "${github_repository.gitops.name}"
  username = "${var.paid_github_member_2}"
  # Permission must, be pull push or admin
  permission = "push"
  depends_on = [
    "github_repository.gitops",
  ]
}

resource "github_repository_collaborator" "gitops_repo_collaborator_3" {
  repository = "${github_repository.gitops.name}"
  username = "${var.paid_github_member_3}"
  # Permission must, be pull push or admin
  permission = "pull"
  depends_on = [
    "github_repository.gitops",
  ]
}

# Variables

variable "app" {
  type    = "string"
  default = "jenkins_master"
}

variable "jenkins_plugins" {
  type = "list"
  default = [
    "pipeline-githubnotify-step",
    "plain-credentials",
    "workflow-job",
    "pipeline-model-api",
    "blueocean-pipeline-editor",
    "performance",
    "blueocean-bitbucket-pipeline",
    "handlebars",
    "blueocean-jwt",
    "antisamy-markup-formatter",
    "cloudbees-folder",
    "workflow-step-api",
    "pipeline-model-extensions",
    "github-oauth",
    "aws-credentials",
    "github-branch-source",
    "ssh-credentials",
    "docker-java-api",
    "blueocean-core-js",
    "jquery-detached",
    "docker-plugin",
    "aws-java-sdk",
    "pipeline-model-declarative-agent",
    "blueocean-config",
    "pipeline-github",
    "blueocean-personalization",
    "ace-editor",
    "blueocean-display-url",
    "cloudbees-bitbucket-branch-source",
    "workflow-cps",
    "github-pullrequest",
    "jenkins-design-language",
    "git-client",
    "scm-api",
    "mailer",
    "pipeline-stage-view",
    "blueocean-jira",
    "blueocean-pipeline-scm-api",
    "pipeline-graph-analysis",
    "blueocean-i18n",
    "matrix-auth",
    "pipeline-stage-step",
    "structs",
    "pipeline-input-step",
    "ssh-slaves",
    "pipeline-maven",
    "workflow-aggregator",
    "jsch",
    "blueocean-executor-info",
    "configuration-as-code-support",
    "display-url-api",
    "pipeline-github-lib",
    "blueocean-events",
    "gradle",
    "blueocean-pipeline-api-impl",
    "blueocean-git-pipeline",
    "ec2",
    "sse-gateway",
    "pipeline-build-step",
    "apache-httpcomponents-client-4-api",
    "durable-task",
    "blueocean-rest",
    "jira",
    "slack",
    "junit",
    "workflow-cps-global-lib",
    "job-dsl",
    "amazon-ecr",
    "node-iterator-api",
    "amazon-ecs",
    "git-server",
    "sonar",
    "matrix-project",
    "mercurial",
    "workflow-durable-task-step",
    "docker-workflow",
    "variant",
    "credentials",
    "pipeline-model-definition",
    "configuration-as-code",
    "blueocean-autofavorite",
    "script-security",
    "pubsub-light",
    "workflow-api",
    "config-file-provider",
    "blueocean-rest-impl",
    "blueocean-github-pipeline",
    "lockable-resources",
    "workflow-multibranch",
    "htmlpublisher",
    "workflow-basic-steps",
    "workflow-scm-step",
    "token-macro",
    "github",
    "momentjs",
    "docker-commons",
    "workflow-support",
    "authentication-tokens",
    "icon-shim",
    "jackson2-api",
    "github-issues",
    "pipeline-milestone-step",
    "github-api",
    "git",
    "blueocean-commons",
    "favorite",
    "bouncycastle-api",
    "blueocean-web",
    "pipeline-stage-tags-metadata",
    "pipeline-rest-api",
    "branch-api",
    "handy-uri-templates-2-api",
    "blueocean-dashboard",
    "credentials-binding",
    "blueocean",
    "gitlab-plugin",
    "hashicorp-vault-plugin",
    "hashicorp-vault-pipeline",
    "pipeline-utility-steps",
    "pipeline-aws"
  ]
}
variable "admin" {
  type    = "string"
  default = "Bruce"
}

variable "region" {
  type    = "string"
  default = "eu-central-1"
}

variable "vpc_cidr_block" {
  type    = "string"
  default = "192.168.1.0/24"
}

variable "ecs_instance_type" {
  type    = "string"
  default = "c3.large"
}

variable "ssh_cidr" {
  type    = "list"
  default = ["2.45.231.44/32"]
}

gcp-project
===========

This project properly configures a given Google Cloud Platform Project for hosting the Accentis project.

## Tooling

This project uses [Terraform](https://terraform.io/) to express the required configuration using code.  The Terraform commands are executed on [Terraform Cloud](https://app.terraform.io/) infrastructure.  In order to satisfy the prerequisites needed to successfully run Terraform commands on Terraform Cloud, refer to the Bootstrapping section below.

## Automation

This project is not automated, because of the following reasons:
* a high level of privilege is necessary to provision the coded resources
* this configuration seldomly changes
* many of the systems that would enable automation, depend on this configuration to be in place

## Bootstrapping

This section describes the prerequisites needed to be able to run Terraform with the CLI.

### Terraform Cloud Workspace

1. Create a workspace in [Terraform Cloud](https://app.terraform.io/) named `accentis-gcp-project-` and the numerical suffix that follows `accentis-` in the GCP project ID.  For example, for GCP project `accentis-111222`, the workspace name is `accentis-gcp-project-111222`.
1. In the created Terraform Cloud workspace, set a **Variable** named **project_id** and set its value to the GCP Project ID.

### GCP Service Account

1. Create a Service Account in the Google Cloud Project using the [Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts) page in the Console.
1. Assign the Project Owner role to the newly created Service Account using the [IAM](https://console.cloud.google.com/iam-admin/iam) page in the Console.
1. Create a Key for the newly created Service Account by clicking on it in the [Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts) page in the Console, then switching to the **Keys** tab, and choose **Create New Key** by opening the **Add Key** button.  When prompted for the format, select the recommended JSON format and click the **Create** button.  A file containing the key will automatically begin downloading to your workstation.
1. Combine all lines in the downloaded file using the following command: `cat $file | tr -d '\n'` and copy the output to the system clipboard.
1. In the created Terraform Cloud workspace, set an **Environment Variable** named **GOOGLE_CREDENTIALS** and set its value to the copied Service Account Key from the previous step.  Check the **sensitive** box to instruct Terraform Cloud not to display this value in the User Interface.

### Terraform Cloud API Token

Once a Terraform Cloud API Token is created, it is cached in the current user's home directory.  However, since the token can be revoked on the Terraform Cloud UI or API, it should be verified periodically.

The following command will confirm that there is a token cached locally and that it is valid:
```
$ curl -fs -o /dev/null -H "Authorization: Bearer $(jq -r '.credentials."app.terraform.io".token' $HOME/.terraform.d/credentials.tfrc.json)" https://app.terraform.io/api/v2/account/details && echo "Token is valid"
```
If the message `Token is valid` appears, everything is fine.  If any other error appears, or the exit status of the command is not 0, then a new token should be created with the following command:
```
$ docker run --rm -it -v $HOME/.terraform.d:/root/.terraform.d hashicorp/terraform:0.15.0 login
```
And follow the on-screen prompts.

## Running

The Terraform commands are invoked locally using the Terraform CLI (running in a Docker container), but for most of them, the actual execution is done remotely on Terraform Cloud infrastructure.  Terraform Cloud also takes care of storing the Terraform state file.

For commands that are executed remotely:
```
$ docker run --rm -it -v $HOME/.terraform.d:/root/.terraform.d:ro -v $PWD:/work -w /work hashicorp/terraform:0.15.0 <command> <args>
```
Where `<command>` is the Terraform command to execute and `<args>` is the list of arguments to pass to that command.

For commands that cannot be executed remotely (like **import**):
```
$ docker run --rm -it -v $HOME/.terraform.d:/root/.terraform.d:ro -v $PWD:/work -w /work -v $HOME/.config/gcloud:/root/.config/gcloud:ro hashicorp/terraform:0.15.0 <command> <args>
```

gcp-project
===========

This project properly configures a given Google Cloud Platform Project for hosting the Accentis project.

## Tooling

This project uses [Terraform](https://terraform.io/) to express the required configuration using code.

## Automation

This project is not automated, because of the following reasons:
* a high level of privilege is necessary to provision the coded resources
* this configuration seldomly changes
* many of the systems that would enable automation, depend on this configuration to be in place

## Running

To run Terraform, to apply this repository's configuration, use the following process:

First, authenticate yourself to establish valid credentials.
```
$ gcloud auth application-default login --no-launch-browser
```

Next, 
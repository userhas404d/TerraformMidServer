# TerraformMidServer

## Terraform Deployable ServiceNow Mid Server

## Overview

This repo contains a set of Terraform modules that deploy a ServiceNow Mid Server. All steps are automated with the exception of MidSever validation and the creation of the MidServer account.

## Prerequisites

- A ServiceNow instance that you have administrative rights to. (see [https://developer.servicenow.com](https://developer.servicenow.com/app.do#!/home))
- A properly configured [MidServer account](https://docs.servicenow.com/bundle/jakarta-servicenow-platform/page/product/mid-server/task/t_SetupMIDServerRole.html)
- A properly configured AWS cli/terraform environment

## Caveats

- Complex passwords are not currently supported due to Character Entity Reference [limitations](https://docs.servicenow.com/bundle/jakarta-servicenow-platform/page/product/mid-server/task/t_SetupMIDServerRole.html) using the current `sed` replace method.
- The expectation is that this is an ephemeral instance. The Mid Server service is not configured to start on system boot.

## How To Use This module

To use this module, modify the `terraform.tfvars` file with your applicable input variables.

In your Terraform working directory, run the following commands:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## ToDo

- Create MidServer account programmatically
- Account for Character Entity References in string replace/xml modifications

# Infrastructure for the Covid Tracker PH project

![Infra Terraform Apply](https://github.com/covidtrackerph/basement/workflows/Infra%20Terraform%20Apply/badge.svg)


The infrastructure the CovidTrackerPH project is built on top of.

## CI/CD

Continuous integration / Continuous deployment is provided by github actions. There are two main pipelines, one for pull requests and one for merges.

> Make sure to always run ``terraform fmt -recursive`` before submitting a PR. The PR pipeline checks for formatting.

## Core

Contains the core infrastructure components.

<img src="https://raw.githubusercontent.com/covidtrackerph/basement/master/graph.svg">

## Deploying the basement to a new AWS account for the first time
* Create a state bucket by modifying and running ``terraform apply`` in the ``tfbase`` folder.
* Update the ``terraform.tfvars`` in the ``core`` folder under the appropriate namespaces.


# Utilities

A set of utility scripts

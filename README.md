# OPHDST Cloud Enablement

## Table of Contents
  - [Overview](#overview)
  - [Getting Started](#getting-started)
  - [Contributing](#contributing)
  - [Troubleshooting](#troubleshooting)

## Overview
The Cloud Enablement effort, existing as a part of the Data Ingestion Building Blocks (DIBBs) triad, aims to enable rapid cloud conversion of existing OPHDST systems, while promoting rapid onboarding of new projects to the CDC External Azure Environment (CDCExt). We offer teams the ability to leverage space within our unified multi-tenant Azure kubernetes cluster for simple workloads, while granting teams the freedom to leverage our tools and guidance to deploy their own custom solutions.

## Searchable Documentation
For more information on how to get started using our tools, please consult our documentation site, _coming soon!_

## Getting Started
To start developing for the Cloud Enablement effort, refer to our [Getting Started](https://github.com/CDCgov/dibbs-cloud/wiki/Getting-Started) wiki page.

## Contributing
To contribute, refer to our [CONTRIBUTING.md](CONTRIBUTING.md).

## Troubleshooting
### TFSEC
To troubleshoot terraform security, or _tfsec_, issues you can run the commands locally. The following commands are for MacOS users:

1. Install tfsec `brew install tfsec`.
2. Run tfsec locally `tfsec`.

You will see what items passed and if there are `critical`, `high`, `medium` security vulnerabilities you will need to resolve before your PR will pass all of the tfsec checks.

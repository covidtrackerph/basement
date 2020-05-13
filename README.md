# Infrastructure for the Covid Tracker PH project


Todo documentation.

# Core

* Api Gateway
* Lambda Functions
    * Case Collector - Lambda that collects case data from DataDrop using Google Drive API v3.
    * Google Verification - Verification for google domains to enable drive watch in the DataDrop shared folder.
    * Graph - GraphQL service
* Lambda
* RDS
* Security Groups
* Subnet
* UI ( Todo, migrate here ) ( Cloudfront + S3 + Route53 )

# TFbase

# Utilities

# Diagram
<img src="https://raw.githubusercontent.com/covidtrackerph/basement/master/graph.svg">
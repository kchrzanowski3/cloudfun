# Overview

Everything is written as code in Terraform. Basic CI/CD pipelines were setup for deploment of infrastructure and images. 

## Cloud Architecture
This is an organization with 4 subnets, managed by Active Directory and a group of workstations. AWS Workspaces is used to spin up Windows 10 
machines as "Users" that are managed by a domain. There is a separate ec2 windows 10 server instance used to managed the domain controllers 
like might be done in an actual enterprise environment. 

![Cloud Architecture](https://github.com/kchrzanowski3/cloudfun/blob/main/readmeimages/AWSADDomainInfra.png?raw=true)

## Deployment Pipeline
A very simple pipeline was stood up to manage deployment. There is some static scanning going on. I experimented with Checkov but ultimately 
liked Snyk's free UI SaaS interface to track the vulnerabilities over time. A future improvement would be intergrating a true Vulnerability 
management tracker like would be used in an enterprise. 

![Deployment Pipeline Architecture](https://github.com/kchrzanowski3/cloudfun/blob/main/readmeimages/AWSADDomainsDeployPipeline.png?raw=true)

## Image Pipeline
A very simple image pipeline with packer was stood up to build custom ami's pre-configured for the Domain Managerement server. This way 
it spins up installed with all the Active Directory management tools necessary to manage the server. I also built an ubuntu server here in the 
image pipeline for fun, but there was no actual reason to do so. I designed the pipeline in a manner so that it will build any new/updated packer 
image and I don't have to maintain a separate pipeline for each image or type of image. I'd definitely use this approach again as it allows me 
to maintain and improve one single pipeline versus many. 

![Image Pipeline Architecture](https://github.com/kchrzanowski3/cloudfun/blob/main/readmeimages/AWSADDomainsImagePipeline.png?raw=true)

## 3 Muskateers
I also expirmented with the [3 Muskateers method](https://3musketeersdev.netlify.app/) of tests/deployment. I defined a makefile that would spin up a docker container 
(defined in a dockerfile) and run a set of (pipeline) tests locally. In a project where a more extensive set of pipeline tests was required, I would
definitely use this again as it lets you run your pipeline tests pre-commit, and get faster feedback. 
But for this project where I was using Github Actions already, it was overkill to maintain alongside the github actions pipeline, so I abandoned it after a while in favor of just running individual commands locally to test (e.g., terraform apply, checkov). 

![3muskateers pattern](https://3musketeersdev.netlify.app/assets/pattern.mmd.aH3SxfCR.svg)

Overview

Everything is written as code in Terraform. Basic CI/CD pipelines were setup for deploment of infrastructure and images. 

![Cloud Architecture](https://github.com/kchrzanowski3/cloudfun/blob/main/readmeimages/AWSADDomainInfra.png?raw=true)

This is an organization with 4 subnets, managed by Active Directory and a group of workstations. AWS Workspaces is used to spin up Windows 10 
machines as "Users" that are managed by a domain. There is a separate ec2 windows 10 server instance used to managed the domain controllers 
like might be done in an actual enterprise environment. 

![Deployment Pipeline Architecture](https://github.com/kchrzanowski3/cloudfun/blob/main/readmeimages/AWSADDomainsDeployPipeline.png?raw=true)

A very simple pipeline was stood up to manage deployment. There is some static scanning going on. I experimented with Checkov but ultimately 
liked Snyk's free UI SaaS interface to track the vulnerabilities over time. A future improvement would be intergrating a true Vulnerability 
management tracker like would be used in an enterprise. 

![Image Pipeline Architecture](https://github.com/kchrzanowski3/cloudfun/blob/main/readmeimages/AWSADDomainsImagePipeline.png?raw=true)

A very simple image pipeline with packer was stood up to build custom ami's pre-configured for the Domain Managerement server. This way 
it spins up installed with all the Active Directory management tools necessary to manage the server. I also built an ubuntu server here in the 
image pipeline for fun, but there was no actual reason to do so. I designed the pipeline in a manner so that it will build any new/updated packer 
image and I don't have to maintain a separate pipeline for each image or type of image. I'd definitely use this approach again as it allows me 
to maintain and improve one single pipeline versus many. 
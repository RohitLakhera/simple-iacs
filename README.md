# Simple IaC Project: Terraform + Jenkins + AWS

Creates one EC2 web server (Apache) with a security group in your default VPC.
Jenkins runs Terraform for you: init -> plan -> approval -> apply.

## Files
- main.tf      : all the infrastructure
- Jenkinsfile  : the pipeline

## Run locally first
    aws configure
    terraform init
    terraform plan
    terraform apply
    # open the website_url from the output (wait ~1 minute for the server to boot)
    terraform destroy

## Run with Jenkins
1. Jenkins machine needs: git, terraform. (Install Terraform, then restart Jenkins.)
2. Add two "Secret text" credentials in Jenkins:
   - aws-access-key-id
   - aws-secret-access-key
3. Push this folder to a GitHub repo.
4. New Item -> Pipeline -> "Pipeline script from SCM" -> Git -> repo URL -> branch main.
5. Build with Parameters -> ACTION=apply -> approve when asked.
6. Open the URL shown in the last stage.
7. To clean up: build again with ACTION=destroy.

## Note
State is stored locally in the Jenkins workspace (kept simple on purpose).
Don't delete the job workspace before running destroy, or Terraform will forget what it created.
The proper fix is an S3 backend, which is the next step to learn.

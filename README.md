# TASK
1. Create a Docker image, that will contain Jenkins installation;
2. For that installation, using Job DSL/Pipeline DSL, create a job-generator,
   that will provision Jenkins instance (same one, master) with JobX.

   JobX - a Jenkins job, that will deploy HTML page (Hello World)
   into Apache server (preferably Dockerized also) and run it.

   Final Jenkins image has to contain 1 job (Generator) to generate another job (JobX).

3. Start Jenkins container from create image and run JobX and display content of HTML page.

# ADDITIONAL TASK
Deploy this setup to AWS:
  - create basic resources for EC2 to run;
  - create EC2 instance, provision it with Docker, run the custom Jenkins image from DockerHub;
  - go to Step 3.
  
  
# COMPLETED
1. Created docker image with jenkins from standard jenkins image from Docker Hub
   [jenkins repository](https://hub.docker.com/_/jenkins/).
   The image is located in Docker Hub [repository](https://hub.docker.com/r/rustamar/jenkins_generator/).
   The final version is rustamar/jenkins_generator:3

   Changes applied to image:
   - installed Job DSL, and Job Generator plugins
   - added private key for access to "apache" instance
   - created Generator job which loads configuration from current git repository (jenkins_pipeline/Jenkinsfile)
2. Created IaaC project in terraform. The project creates environment in AWS for current task
   ##### Resources created in ECS:
   - VPC
   - Subnet
   - AMI roles for load balancer and ecs
   - Security Group
   - ALB, auto scaling group, ECS cluster, service, task for jenkins
   - ECS service and task for http. The service and task are located in the same cluster as jenkins
   - Key pair "admin" for access to the ECS instance

   ##### Create environment
   - install terraform - https://www.terraform.io/intro/getting-started/install.html
   - cd to ecs folder
   - fill fields in sensitive.tf - https://www.terraform.io/intro/getting-started/build.html
   - run _terraform plan_
   - run _terraform apply_
   - output should show value for aws_alb.jenkins.dns_name. It is jenkins application url
   - check httpd server. Have to get value from get_httpd.sh script or AWS Web Console in instance parameters (IPv4 Public IP).
   - login to jenkins (admin/admin)
   - run Generator job
   - check httpd server again
3. **Destroy environment in AWS**
   run command _terraform destroy_. Answer yes and all resources should be removed

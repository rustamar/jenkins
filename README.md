# TASK

1. Create a Docker image, that will contain Jenkins installation;

2. For that installation, using Job DSL/Pipeline DSL, create a job-generator, that will provision Jenkins instance (same one, master) with JobX.

   JobX - a Jenkins job, that will deploy HTML page (Hello World) into Apache server (preferrably Dockerized also) and run it.

   Final Jenkins image has to contain 1 job (Generator) to generate another job (JobX).

3. Start Jenkins container from create image and run JobX and display content of HTML page.

# ADDITIONAL TASK

Deploy this setup to AWS:
  - create basic resources for EC2 to run;
  - create EC2 instance, provision it with Docker, run the custom Jenkins image from DockerHub;
  - go to Step 3.
  
  
# Completed
1. jenkins_docker - standard jenkins docker image without volume

   pre configured jenkins image is located in docker hub: rustamar/jenkins_generator:2
2. jenkins_pipeline - jenkins generator job code
3. ecs - terraform code for deploying jenkins and httpd docker images to aws alb ecs


# TODO
* security (add private key to jenkins for deploying HTML page to httpd, and public key to httpd)
* add volume to aws ecs task definition
* how get httpd ip? (public ip?)

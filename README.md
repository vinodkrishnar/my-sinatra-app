REA Systems Engineer practical task
===================================

Purpose
=======
To propose and document the methods and scripts that could be used to deploy the Sinatra ruby application  - https://github.com/rea-cruitment/simple-sinatra-app

Prerequisite
============

 - AWS account with a VPC and 3 subnets.
 - An S3 Bucket that holds the ruby app as a zip file
 - Private Ip range to use in the ALB and EC2 Security Groups. 
 - A Laptop/server with Docker and AWS CLI installed, to call Cloudformation APIs. 
 - The Laptop/Server should be configured with your access key/secret key pairs OR an IAM role that you could assume to run the 
   Cloudformation commands.

Approach 1
==========

Application running on an EC2 Instance 
--------------------------------------
- The architecture consists of a CloudFormation stack that creates 
  - Frontend ALB, Target Groups and HTTP Listener. 
  - EC2 and ELB Security Groups. 
  -	IAM Role and Instance Profile to talk to S3.
  -	EC2 instance from Amazon LinuxII AMI.

Detailed Explanation
--------------------
 - An EC2 instance running on a private subnet will host the application. 
 - The UserData runs the script during boot to download the application from a Shared S3 bucket and start the ruby 
   app that listens on Port80. 
 - The EC2 instance is front ended by an ALB that listens only on Port 80. 
 - The introduction of ALB in front of the EC2 instance and the communication between them (only on Port 80 )  with their respective
   security groups ensures security and reduces the blast radius in case of an attack. 
 - Run the CloudFormation cli command to create the stack. The template and the sample parameter.json is included in the source code. 
   Make sure the parameters are changed to values that match your environment/AWS Account. 

Command to Execute
------------------

Please make sure the path of the template and paramter file match you local. 

`aws cloudformation create-stack --stack-name sinatra-app   --template-body  file://~/code/my-sinatra-app/my-sinatra-app.yaml --parameter file://~/code/my-sinatra-app/my-sinatra-app-parameters.json --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND`

Once the Stack is created the url to the app will be available from the output section.

Approach 2
==========

Application running as a docker Image
-------------------------------------

Running the app as a Container is recommended as it easily portable and can leverage all the advantages of running as a microservice. The app can be built and stored as an Image in ECR or any registry of our choice. The Dockerfile as shown below for running the app has been included in the Source Code. 


`FROM amazonlinux:latest`

`USER root`

`RUN mkdir /app`

`RUN yum install -y \`
     `gem \ `
     `curl \`
     `wget \`
     `zip  \`
     `unzip `

`# Install AWS CLI`
`RUN curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip  -o awscli-bundle.zip \`
    `&& unzip awscli-bundle.zip \ `
    `&& ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws`

`# install bundler`    
`RUN gem install bundler -v '~>1'`

`COPY ./app/ /app/`

`RUN  cd /app && /usr/local/bin/bundle install `

`EXPOSE 80`

`ENTRYPOINT ["sh", "-c"]`
`CMD ["cd /app/ && /usr/local/bin/rackup -p 80 --host 0.0.0.0"]`

- The Steps for running the container is as shown below.

  - Download the GitHub repo to your local machine ,go to the folder that has the DockerFile and execute the command

      `docker build -t my-sinatra-app:1.0 `

    This will build the image. Verify the newly created image using the command below and note the image ID
         
      `docker images`

  - Run/start the container. 

    `docker run -d --name my-sinatra-app  -p  5000:80 <ImageID> `
	
This would start the container named my-sinatra-app in detached mode and expose Port 5000 as the host port

 - Verify the app by calling the URL http://localhost:5000 in the browser. You should see a Hello World Page. 

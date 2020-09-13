FROM amazonlinux:latest

USER root

RUN mkdir /app

RUN yum install -y \
     gem \ 
     curl \
     wget \
     zip  \
     unzip 

# Install AWS CLI
RUN curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip  -o awscli-bundle.zip \
    && unzip awscli-bundle.zip \ 
    && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# install bundler    
RUN gem install bundler -v '~>1'

COPY ./app/ /app/

RUN  cd /app && /usr/local/bin/bundle install 

EXPOSE 80

ENTRYPOINT ["sh", "-c"]
CMD ["cd /app/ && /usr/local/bin/rackup -p 80 --host 0.0.0.0"]


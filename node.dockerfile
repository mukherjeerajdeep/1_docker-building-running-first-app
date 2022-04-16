# Build: docker build -f node.dockerfile -t danwahlin/nodeapp .

# Option 1: Create a custom bridge network and add containers into it

# docker network create --driver bridge isolated_network
# docker run -d --net=isolated_network --name mongodb mongo

# NOTE: $(pwd) in the following line is for Mac and Linux. See https://blog.codewithdan.com/docker-volumes-and-print-working-directory-pwd/ for Windows examples.
# docker run -d --net=isolated_network --name nodeapp -p 3000:3000 -v $(pwd)/logs:/var/www/logs danwahlin/nodeapp

# Seed the database with sample database
# Run: docker exec nodeapp node dbSeeder.js

# Option 2 (Legacy Linking - this is the OLD way)
# Start MongoDB and Node (link Node to MongoDB container with legacy linking)
 
# docker run -d --name my-mongodb mongo
# docker run -d -p 3000:3000 --link my-mongodb:mongodb --name nodeapp danwahlin/nodeapp

# So it could be a specific alpine package
FROM        node:alpine

LABEL       author="Dan Wahlin"

# buildversion can be passed from the docker-compose.yaml during the build
ARG         buildversion 

# Set packages with nano
ARG         PACKAGES=nano

# This can be passed from the docker-compose.yaml
ENV         NODE_ENV=production
ENV         PORT=3000

# This can be passed from the docker-compose.yaml
ENV         build=$buildversion

ENV         TERM=xterm

RUN         apk update && apk add $PACKAGES

WORKDIR     /var/www

# Before npm install we can be very sure that the dependancies are installed 
# first then the other copying action to perform. This will be first layer of the
# docker file and then the upcoming layers will follow.
COPY        package.json package-lock.json ./
RUN         npm install

# Could also be . /var/www but this is redundant
# The first . is the local source directory where the dockerfile is living
# The second . says the /var/www which is the WORKDIR, so copy everything frm current directory 
# to the WORKDIR
COPY        . ./

# Expose the port thorugh the environment variable
EXPOSE      $PORT

# RUN a specifc command if we want
RUN         echo "Build version: ${build}"

# What to run during that run
ENTRYPOINT  ["npm", "start"]

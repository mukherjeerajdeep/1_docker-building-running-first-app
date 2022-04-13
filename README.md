# Node.js with MongoDB and Docker Demo

Application demo designed to show how Node.js and MongoDB can be run in Docker containers. 
The app uses Mongoose to create a simple database that stores Docker commands and examples. 

Interested in learning more about Docker? Visit https://www.pluralsight.com/courses/docker-web-development to view my Docker for Web Developers course.

### Starting the Application with Docker Containers:

1. Install Docker for Windows or Docker for Mac (If you're on Windows 7 install Docker Toolbox: http://docker.com/toolbox).

2. Open a command prompt.

3. Run the commands listed in `node.dockerfile` (see the comments at the top of the file).

4. Navigate to http://localhost:3000. Use http://192.168.99.100:8080 in your browser to view the site if using Docker toolbox. This assumes that's the IP assigned to VirtualBox - change if needed.


### Starting the Application with Docker Compose

1. Install Docker for Windows or Docker for Mac (If you're on Windows 7 install Docker Toolbox: http://docker.com/toolbox).

2. Open a command prompt at the root of the application's folder.

3. Run `docker-compose build`

4. Run `docker-compose up`

5. Open another command prompt and run `docker ps -a` and note the ID of the Node container

6. Run `docker exec -it <nodeContainerID> sh` (replace <nodeContainerID> with the proper ID) to sh into the container

7. Run `node dbSeeder.js` to seed the MongoDB database

8. Type `exit` to leave the sh session

9. Navigate to http://localhost:3000 (http://192.168.99.100:3000 if using Docker Toolbox) in your browser to view the site. This assumes that's the IP assigned to VirtualBox - change if needed.

10. Run `docker-compose down` to stop the containers and remove them.

## To run the app with Node.js and MongoDB (without Docker):

1. Install and start MongoDB (https://docs.mongodb.com/manual/administration/install-community/).

2. Install the LTS version of Node.js (http://nodejs.org).

3. Open `config/config.development.json` and adjust the host name to your MongoDB server name (`localhost` normally works if you're running locally). 

4. Run `npm install`.

5. Run `node dbSeeder.js` to get the sample data loaded into MongoDB. Exit the command prompt.

6. Run `npm start` to start the server.

7. Navigate to http://localhost:3000 in your browser.


### My Notes and commands for Docker Learning 

1. Check the images you have downloaded or created by `docker images`
2. The images can be deleted by `docker rmi <image-id>` command. 
3. Someone can create a image and then can push to upstream repository which is called as registry, here we used the docker.hub.
4. The dockerfile is a important piece of information and it contains a lot of data layers to build the image layer by layer. 

```Dockerfile
# So it could be a specific alpine package
FROM        node:alpine

LABEL       author="Dan Wahlin"

# ARG         PACKAGES=nano

ENV         NODE_ENV=production
ENV         PORT=3000

# ENV         TERM xterm
# RUN         apk update && apk add $PACKAGES

WORKDIR     /var/www

# Before npm install we can be very sure that the dependancies are installed 
# first then the other copying action to perform. This will be first layer of the
# docker file and then the upcoming layers will follow.
COPY        package.json package-lock.json ./
RUN         npm install

# Could also be . /var/www but this is redundant
# The first . is the local source directory where the dockerfile is living
# The second . says the /var/www the WORKDIR, so copy everything frm current directory 
# to the WORKDIR
COPY        . ./

# Expose the port thorugh the environment variable
EXPOSE      $PORT

# What to run during that run
ENTRYPOINT  ["npm", "start"]
```
5. So during the image build from the dockerfile we need to specify the file by either putting a `.` or the name od the file by `-f <file-name>` in this case it is `node.dockerfile` so then during the build docker can understand it. 
6. Once the image is built it can be executed locally or can be pushed. 
7. Running the container locally is done by `docker run -p 3000:3000 -d mukherjeerajdeep/nodeapp:3.0` here the 
   1. `-p` is denoting the port mapping.
   2. `-d` means it will be executed in detached mode so no log will be shown.
   3. If the docker run is executed on the image which is present locally then the container will be created from there otherwise it will be pulled from the `hub.docker.com` of users account.  
8. Check the running containers by `docker ps -a`

CONTAINER ID   IMAGE                          COMMAND                  CREATED          STATUS                      PORTS                    NAMES
eb93ffbf1043   mukherjeerajdeep/nodeapp:3.0   "npm start"              7 seconds ago    Up 5 seconds                0.0.0.0:3000->3000/tcp   

9. If it is exited means something wrong happened 

CONTAINER ID   IMAGE                          COMMAND                  CREATED              STATUS                      PORTS     NAMES
eb93ffbf1043   mukherjeerajdeep/nodeapp:3.0   "npm start"              About a minute ago  `Exited (1) 42 seconds ago`             nice_gagarin

10. Check the logs with `docker logs <container-id>` something bad happened with the mongo connection

Trying to connect to mongodb/funWithDocker MongoDB database
(node:18) [MONGODB DRIVER] Warning: promiseLibrary is a deprecated option
(Use `node --trace-warnings ...` to show where the warning was created)
[production] Listening on http://localhost:3000

11. 




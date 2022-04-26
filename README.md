## My Notes and commands for Docker Learning 

1. Check the images you have downloaded or created by `docker images`
2. The images can be deleted by `docker rmi <image-id>` command. 
3. Someone can create a image and then can push to upstream repository which is called as registry, here we used the docker.hub.
4. The dockerfile is a important piece of information and it contains a lot of data layers to build the image layer by layer. 

```Dockerfile
# DOCKER EXAMPLE FILE

# So it could be a specific alpine package
FROM        node:alpine

LABEL       author="Dan Wahlin"

# This can be passed from the docker-compose during the build.
# These are build-time constructs
ARG         buildversion 

ENV         NODE_ENV=production
ENV         PORT=3000

# Based on the ARG "buildversion" this environment can be set
# This can be passed from the compose, this is similar to the command `docker run -p <ports> --env    NODE_ENV=production <imageToRun>`
ENV         build=$buildversion

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

# RUN a specifc command if we want
RUN         echo "Build version: ${build}"

# What to run during that run
# Sometimes this one is used with CMD as well so to give a choice 
# to user to override the passed parameter during running of container.
ENTRYPOINT  ["npm", "start"] 

# The CMD and ENTRYPOINT are run-time constructs/variables.
```

5. So during the image build from the dockerfile we need to specify the file by either putting a `.` or the name od the file by `-f <file-name>` in this case it is `node.dockerfile` so then during the build docker can understand it.
   
6. Docker container can also be executed and deleted once the work is done by `docker container run --rm nginx` the --rm flag which means remove.  

7. Once the image is built it can be executed locally or can be pushed. 

8. Running the container locally is done by `docker run -p 3000:3000 -d mukherjeerajdeep/nodeapp:3.0` here the 
   1. `-p` is denoting the port mapping.
   2. `-d` means it will be executed in detached mode so no log will be shown.
   3. If the docker run is executed on the image which is present locally then the container will be created from there otherwise it will be pulled from the `hub.docker.com` of users account.  

9.  Check the running containers by `docker ps -a`
```text
CONTAINER ID   IMAGE                          COMMAND                  CREATED          STATUS                      PORTS                    NAMES
eb93ffbf1043   mukherjeerajdeep/nodeapp:3.0   "npm start"              7 seconds ago    Up 5 seconds                0.0.0.0:3000->3000/tcp   
```

9. If it is exited means something wrong happened 
```text
CONTAINER ID   IMAGE                          COMMAND                  CREATED              STATUS                      PORTS     NAMES
eb93ffbf1043   mukherjeerajdeep/nodeapp:3.0   "npm start"              About a minute ago  `Exited (1) 42 seconds ago`             nice_gagarin
```

10. Check the logs with `docker logs <container-id>` something bad happened with the mongo connection
    
```text
Trying to connect to mongodb/funWithDocker MongoDB database
(node:18) [MONGODB DRIVER] Warning: promiseLibrary is a deprecated option
(Use `node --trace-warnings ...` to show where the warning was created)
[production] Listening on http://localhost:3000
```
11. Removing container can be done by `docker rm <container-id>` and that will remove it from the service as well.
    
12. The volume mount can be used in two ways :
    1.  It seems as the `production` use where the logs from the container are redirected to an external media like some database or in local machine. The command to be used is `docker run -p 3000:3000 -v ${PWD}/logs:/var/www/logs mukherjeerajdeep/nodeapp:3.0` Here the container app usually writes data at `var/www/logs` however we redirected it by saying.
        1.  `{PWD}` - local directory where we are currently in and running the docker command. 
        2.  Then traversing to /logs folder as similar like container. Hence `{PWD}/logs`

    **Note** : The parameter in the left of `:` refers the local machine whereas the right shows the folders/path inside the container.

    **Note** : It can alos be done with bind mount system which is newer than the volume mount. `docker run -p 3000:3000 --mount type=bind,source=${PWD}/logs,target=/var/www/logs mukherjeerajdeep/nodeapp:3.0`

    1. The other way is the kind of `developement` environement type where the container fetches data runtime to show towards the user. The command executed as `docker run -p 8080:80 -v ${PWD}/nginx:/usr/share/nginx/html nginx:alpine` exactly similar like above but here is two difference. 
       1. The flow is opposite than before it means what we write in the index.html inside the nginx folder will be thrown by the container. 
       2. It's dynamic and can be changed everytime. We exploited that path `/usr/share/nginx/html` nginx usually fetches the html files from this place and shows up in browser.

     **Note** : In this case we are in the same NodeAPP folder and in the left of `:` we have the source that is local machine and destination is remote machine i.e. container. 

13. Creating the network is a bridge between the containers and this is how the containers talk to each other. The command used to see current networks is `docker network ls` and the creation of the network can be done as `docker network create --driver bridge isolated_network` where tje `--driver` is denoted the type of the network and then the network name which is here `isolated_network`. Once the network is created we can connect our containers by them.
  
    1.  Here is the print :
```text
PS C:\Rajdeep_Mukherjee\Dan_W_Dcoker\NodeExpressMongoDBDockerApp> docker network ls
NETWORK ID     NAME               DRIVER    SCOPE
eb766a091add   bridge             bridge    local
0b3ba88f12e5   host               host      local
d0f06edc4fc9   isolated_network   bridge    local <-- This is our network>
1179eaf8430c   none               null      local
```
14. Now the connections are done as follows.
    1. The mongo is connected as `docker run -d --net=isolated_network --name mongodb mongo`
    2. The app is connected as `docker run -d --net=isolated_network --name nodeapp -p 3000:3000 -v $(pwd)/logs:/var/www/logs danwahlin/nodeapp` remember for windows it will be `{PWD}`. Check out the the `--net=isolated_network` which says the network name and also the `--name <container-name>` is important because the /config file mentioned the name and we need to use the same name otherwise the app will never able to connect the database.

15.  To connect the container shell we can use `docker exec -it <container-name> sh` the use of sh/bash/powershell depends on the type of container. Instructor here used the seeder script to populate the db through the app `docker exec nodeapp node dbSeeder.js`. Once this is setup we can see the tables inside the app.
    
16.  This is the same way we build the `docker-compose` file which conforms the YAML format and there are certain rules for that. 

```yaml
# DOCKER-COMPOSE EXAMPLE FILE

version: '3.7'

# Many services can be build together, hence the compose is powerful. In this example only node is built, but there 
services:                         #  can be many like java, python services can be build together. ** Mongo is not built
  node:
    container_name: nodeapp       # name of the container after docker compose creates it.
   
    image: nodeapp                # image to use for building containers, it can be a already exisiting image from some registry or build that image before building containers looking at the build properties below. 
    build:                        # determine how the images will be build instructed by docker-compose
      context: .                  # `.` here means the same root folder where the docker-compose.yaml file resides
      dockerfile: node.dockerfile # dockerfile to use when building the image. user can specify it here.
      args:
        PACKAGES: "nano wget curl"
        buildversion: 1           # Argument can be passed in `docker-compose`. Will be used during buildifn of image.
    environment:                  # `ENV` variables can also be passed as `ARG's`, These enviroments will be set when container will be executed from the image. So inside the running container. 
      - NODE_ENV=production
      - PORT=3000
      - build=1
    env_file: 
      - <file-path>               # supply a environment file during the build, http://bityl.pl/pCBuM
      - ./common.env              # Example of the file
    ports:
      - "3000:3000"
    networks:                     # network names specifier
      - nodeapp-network
    volumes:                      # volume specifier for app logs. Here the container logs will be written
      - ./logs:/var/www/logs
    environment:
      - NODE_ENV=production
      - APP_VERSION=1.0
    depends_on:                   # this says the mongo-db should come up earlier than this app, otherwise fail
      - mongodb

 # Mongo doesn't have the key with build, it taken straight from the docker hub. 
  mongodb:                        # bring up mongodb as a service
    container_name: mongodb
    image: mongo
    networks:                     # connected to same network as the app
      - nodeapp-network

networks:
  nodeapp-network:                # name of the network which will connect the containers 
    driver: bridge                # which type of network is used.
```

Now different command like docker-compose build/up/down will wok to build the container, make them up and working as taking them down when user want to do that. 

17. Similar like `docker ps` to check the status of the published docker containers as a service same thing can be done with the `docker compose` as well. The command is `docker compose ps` after the `docker compose up` is fired.

18. If someone don't want to see the logs then they can use `docker compose up -d` command, here the `-d` means detached mode.

19. Ther are few commands that may be useful in case one of the service out of two services are brought dowan dto correct something and them bring them back with the existing service i.e. the database service, for example we don't want to initiate or let our app to hang due to a dependancy towards the container database. In that case we would use a different compose `docker compose up -d --no-deps [service-name]` remember that here the `docker compose start [service]` will not work once the `service` i.e. here the `node` is removed from the bundle.

```yaml
version: '3.7'

services:   
  node:                         # First service, service name is node 
    .....
  mongodb:                      # Second service, service name is mongodb
    .....

```
20. Looking into the docker compose executed container logs is same as looking into the individual container logs however that can be used as `docker compose logs [servicename] --tail=<number of lines to check>`. The service name can be `node` or `mongodb` as we have seen above.

21. Same as the use for the shelling into a container but with service name as the docker compose used container. The same will work as `docker compose exec -it [servicename] sh` as before. It is a little different than `docker exec -it` we used earlier.

22. The `exec` command will shell into the container and here we can see that the environment set inside the docker container which came from the dockerfile `ENV` and also from the passed argument `ARG` from the docker compose.
    
```text
PS C:\Rajdeep_Mukherjee\Dan_W_Dcoker\NodeExpressMongoDBDockerApp> docker compose exec node sh
/var/www #
/var/www # env
NODE_VERSION=17.9.0
HOSTNAME=80d12467e8f6
YARN_VERSION=1.22.18
SHLVL=1
PORT=3000                                                              # We set this in dockerfile
HOME=/root
TERM=xterm                                                             # We set this in dockerfile
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
build=1                                                                # We set this in compose.yaml
PWD=/var/www                                                           # We set this in dockerfile, by WORKDIR 
NODE_ENV=production                                                    # We set this in compose.yaml
APP_VERSION=1.0                                                        # We set this in compose.yaml 
/var/www #
```
**note**: We can even supply the `environmental` variable during the `exec` command. Check the help below with `-e` options.

```text
PS C:\Rajdeep_Mukherjee\Dan_W_Dcoker\NodeExpressMongoDBDockerApp> docker compose exec --help

Usage:  docker compose exec [options] [-e KEY=VAL...] [--] SERVICE COMMAND [ARGS...]

Execute a command in a running container.

Options:
  -d, --detach                       Detached mode: Run command in the
                                     background.
 ` -e, --env stringArray              Set environment variables`
      --index int                    index of the container if there are
                                     multiple instances of a service
                                     [default: 1]. (default 1)
  -T, --no-TTY docker compose exec   Disable pseudo-TTY allocation. By
                                     default docker compose exec
                                     allocates a TTY.
      --privileged                   Give extended privileges to the process.
  -u, --user string                  Run the command as this user.
  -w, --workdir string               Path to workdir directory for this
                                     command.
```

23. We can scale up the containers by `docker compose` with `--scale` command. So the full command is 

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
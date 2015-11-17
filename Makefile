OSTYPE = $(shell uname)

ifeq ($(OSTYPE), Linux)

DOCKER_STOP             = sudo docker stop
DOCKER_PS               = sudo docker ps
DOCKER_RM               = sudo docker rm
DOCKER_RMI              = sudo docker rmi

DOCKER_RUN              = sudo docker run 
DOCKER_BUILD            = sudo docker build
DOCKER_PUSH             = sudo docker push
DOCKER_PULL             = sudo docker pull

else
ifeq ($(OSTYPE), Darwin)

DOCKER_STOP             = docker stop
DOCKER_PS               = docker ps
DOCKER_RM               = docker rm
DOCKER_RMI              = docker rmi

DOCKER_RUN              = docker run 
DOCKER_BUILD            = docker build
DOCKER_PUSH             = docker push
DOCKER_PULL             = docker pull

endif
endif

NAME_CDP_MONGODB          = cdp-mongodb
NAME_CDP_MONGODBS         = cdp-mongodb-script

DOCKER_CDP_MONGODB_VOLUME = -v /var/cdp/mongo:/data/db

DOCKER_CDP_MONGODB_NAME   = --name $(NAME_CDP_MONGODB)
DOCKER_CDP_MONGODB_IMAGE  = cdporg/cdp-mongodb
DOCKER_CDP_MONGODB_LINK = --link cdp-mongodb:cdp-mongodb

.PHONY: image-build image-push run stop command

image-build:
	$(DOCKER_BUILD) -t $(DOCKER_CDP_MONGODB_IMAGE) --no-cache .

image-push:
	@$(DOCKER_PUSH) $(DOCKER_CDP_MONGODB_IMAGE)

image-pull:
	@$(DOCKER_PULL) $(DOCKER_CDP_MONGODB_IMAGE)

image-destroy:
	$(DOCKER_RMI) $(DOCKER_CDP_MONGODB_IMAGE)

run:
	@$(DOCKER_RUN) -d $(DOCKER_CDP_MONGODB_NAME) $(DOCKER_CDP_MONGODB_VOLUME) $(DOCKER_CDP_MONGODB_IMAGE) mongod --smallfiles --noscripting

run-debug:
	@$(DOCKER_RUN) -t -i --rm $(DOCKER_CDP_MONGODB_NAME) $(DOCKER_CDP_MONGODB_VOLUME) $(DOCKER_CDP_MONGODB_IMAGE) mongod --smallfiles

stop:
	@$(DOCKER_STOP) $(NAME_CDP_MONGODB)
	@$(DOCKER_PS) -a | grep $(DOCKER_CDP_MONGODB_IMAGE) | awk '{ print $$1 }' | xargs $(DOCKER_RM)

command:
	@$(DOCKER_RUN) -t -i --rm $(DOCKER_CDP_MONGODB_NAME) $(DOCKER_CDP_MONGODB_VOLUME) $(DOCKER_CDP_MONGODB_IMAGE) /bin/sh

mongo-drop-db:
	@$(DOCKER_RUN) --rm -i -t $(DOCKER_CDP_MONGODBS_NAME) $(DOCKER_CDP_MONGODB_LINK) $(DOCKER_CDP_MONGODB_VOLUME) $(DOCKER_CDP_MONGODB_IMAGE) mongo --quiet --host cdp-mongodb --eval 'db.getMongo().getDBNames().forEach(function(i){ var db_name = String(db.getSiblingDB(i)); var patt = new RegExp("$(patter)"); if( patt.test(db_name) ) { print("Dropping DB: " + db.getSiblingDB(i)); db.getSiblingDB(i).dropDatabase() } })'

mongo-console:
	@$(DOCKER_RUN) --rm -i -t $(DOCKER_CDP_MONGODBS_NAME) $(DOCKER_CDP_MONGODB_LINK) $(DOCKER_CDP_MONGODB_VOLUME) $(DOCKER_CDP_MONGODB_IMAGE) mongo --host cdp-mongodb
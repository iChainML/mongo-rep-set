FROM centos:7

ENV MONGO_MAJOR 3.6
ENV MONGO_VERSION 3.6.5
ENV MONGO_PACKAGE mongodb-org
ENV MONGO_SCRIPTS_DIR /opt/mongo/scripts
ENV MONGO_KEYFILE /opt/mongo/keyfile

# create user/group
RUN groupadd -r mongodb && useradd -r -g mongodb mongodb

# install dependencies
COPY scripts/install_deps.sh $MONGO_SCRIPTS_DIR/install_deps.sh
RUN $MONGO_SCRIPTS_DIR/install_deps.sh

# mongod config
ENV MONGO_AUTH true
ENV MONGO_STORAGE_ENGINE wiredTiger
ENV MONGO_DB_PATH /data/db
ENV MONGO_JOURNALING true
ENV MONGO_REP_SET rs0
ENV MONGO_SECONDARY mongo2:27017
ENV MONGO_ARBITER mongo3:27017

# mongo root user (change me!)
ENV MONGO_ROOT_USER root
ENV MONGO_ROOT_PASSWORD root123

# mongo app user + database (change me!)
ENV MONGO_APP_USER myAppUser
ENV MONGO_APP_PASSWORD myAppPassword
ENV MONGO_APP_DATABASE myAppDatabase

COPY scripts $MONGO_SCRIPTS_DIR

VOLUME /data/db /data/configdb

EXPOSE 27017 28017

WORKDIR $MONGO_SCRIPTS_DIR

ENTRYPOINT ["./entrypoint.sh"]

CMD ["./run.sh"]

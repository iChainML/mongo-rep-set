#!/bin/bash

set -e

printf "\n[-] Installing base OS dependencies...\n\n"

# base
yum update -y
yum install -y ca-certificates openssl numactl wget



# generate a key file for the replica set
# https://docs.mongodb.com/v3.4/tutorial/enforce-keyfile-access-control-in-existing-replica-set
printf "\n[-] Generating a replica set keyfile...\n\n"
openssl rand -base64 741 > $MONGO_KEYFILE
chown mongodb:mongodb $MONGO_KEYFILE
chmod 400 $MONGO_KEYFILE


# install Mongo
printf "\n[-] Installing MongoDB ${MONGO_VERSION}...\n\n"

MONGO_FILE=mongodb-linux-x86_64-rhel70-${MONGO_VERSION}

wget http://downloads.mongodb.org/linux/${MONGO_FILE}.tgz
tar xf ${MONGO_FILE}.tgz
cp -r ${MONGO_FILE}/bin/* /usr/bin/
rm -rf ${MONGO_FILE}.tgz ${MONGO_FILE}

# cleanup
printf "\n[-] Cleaning up...\n\n"

rm -rf /var/lib/mongodb

#apt-get purge -y --auto-remove openssl wget

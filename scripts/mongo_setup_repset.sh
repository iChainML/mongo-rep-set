#!/bin/bash

echo "************************************************************"
echo "Setting up replica set"
echo "************************************************************"

mongo admin --eval "help" > /dev/null 2>&1
RET=$?

while [[ RET -ne 0 ]]; do
  echo "Waiting for MongoDB to start..."
  mongo admin --eval "help" > /dev/null 2>&1
  RET=$?
  sleep 1

  if [[ -f /data/db/mongod.lock ]]; then
    echo "Removing Mongo lock file"
    rm /data/db/mongod.lock
  fi
done

HOSTNAME="`hostname`"
# Login as root and configure replica set
echo "**** initialize replset ****"
mongo admin -u $MONGO_ROOT_USER -p $MONGO_ROOT_PASSWORD --eval "rs.initiate({
	_id:'${MONGO_REP_SET}',
	members:[{
		_id:0,
		host:'${HOSTNAME}'
	}]
});"

waitForMongo(){
	while true; do
		echo "wait for host $1"
    if mongo --quiet "$1/test" --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)'; then
			break
		fi
		sleep 3
	done
}

echo "waiting for host ${MONGO_SECONDARY} become available"
waitForMongo ${MONGO_SECONDARY}
mongo admin -u $MONGO_ROOT_USER -p $MONGO_ROOT_PASSWORD --eval "rs.add('$MONGO_SECONDARY');"

echo "waiting for host ${MONGO_ARBITER} become available"
waitForMongo ${MONGO_ARBITER}
mongo admin -u $MONGO_ROOT_USER -p $MONGO_ROOT_PASSWORD --eval "rs.addArb('$MONGO_ARBITER');"

#!/bin/bash -x
if [ "$1" == "-h" ]; then
  cat <<-HERE_DOC
Dump production database to local neo4j.
Example usage:
  bin/dump_db.sh development
  bin/dump_db.sh development downloaded
HERE_DOC
  exit 1
fi
if [ "$1" == "" ]; then
  cat <<-HERE_DOC
Please provide environment to which you want to insert data, like:
  bin/dump_db.sh development
HERE_DOC
  exit 1
fi

env=$1
downloaded=$2
server_url=192.168.1.3

GRAPH_DB_PATH=db/neo4j/$env/data/databases/graph.db
REMOTE_DB_PATH=/var/lib/neo4j/data/databases/graph.db
OUTPUT=graphdb.$(date '+%F').zip
bundle exec rails neo4j:stop[$env]
echo removing $GRAPH_DB_PATH
rm -rf $GRAPH_DB_PATH
mkdir $GRAPH_DB_PATH

if [ "$downloaded" != 'downloaded' ]; then
  echo downloading database
  ssh $server_url "cd $REMOTE_DB_PATH; zip -r ~/neo4j/$OUTPUT ."
  echo 'downloading'
  scp $server_url:~/neo4j/$OUTPUT tmp/
else
  echo skipping ssh and use downloaded db
fi
unzip tmp/$OUTPUT -d $GRAPH_DB_PATH
bundle exec rails neo4j:start[$env]
sleep 3
bundle exec rake neo4j:migrate
echo done

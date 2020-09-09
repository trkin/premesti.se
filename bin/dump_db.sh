#!/bin/bash -x
if [ "$1" == "-h" ]; then
  cat <<-HERE_DOC
Dump production database to local neo4j.
Example usage:
  bin/dump_db.sh development
  bin/dump_db.sh development tmp/graph.2020-09-07.zip
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
filepath=$2

# SERVER_URL=192.168.1.3
SERVER_URL=d.trk.in.rs
GRAPH_DB_PATH=db/neo4j/$env/data/databases/graph.db
REMOTE_DB_PATH=/var/lib/neo4j/data/databases/graph.db
bundle exec rails neo4j:stop[$env]
echo removing $GRAPH_DB_PATH
rm -rf $GRAPH_DB_PATH
mkdir $GRAPH_DB_PATH

if [ -z "$filepath" ]
then
  filename=graphdb.$(date '+%F').zip
  filepath=tmp/$filename
  echo downloading database
  ssh $SERVER_URL "cd $REMOTE_DB_PATH; zip -r ~/neo4j/$filename ."
  echo 'downloading'
  scp $SERVER_URL:~/neo4j/$filename $filepath
else
  echo skipping ssh and use downloaded db $filepath
fi
unzip $filepath -d $GRAPH_DB_PATH
bundle exec rails neo4j:start[$env]
sleep 3
bundle exec rake neo4j:migrate
echo done

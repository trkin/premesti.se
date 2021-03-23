# Provision on EC2 Ubuntu 20


Check that you can ssh to server and create a folder and a link to it

```
export SERVER_IP=54.164.74.179
export PEM_FILE=~/config/keys/pems/test-trk-in-rs-us-east-1.pem
ssh -i $PEM_FILE ubuntu@$SERVER_IP
mkdir premesti.se/releases/20201212121212/bin -p
ln -s /home/ubuntu/premesti.se/releases/20201212121212 /home/ubuntu/premesti.se/current
```

Upload provision script

```
scp -i $PEM_FILE bin/provision_ruby.sh ubuntu@$SERVER_IP:/home/ubuntu/premesti.se/current/bin
```

Run on on remote server (you can repeat this commands if something fails)
```
ssh -i $PEM_FILE ubuntu@$SERVER_IP
~/premesti.se/current/bin/provision_ruby.sh
```

Configure password, using original neo4j/neo4j is only for first time:

```
cypher-shell
sername: neo4j
password: *****
Password change required
new password: **********
Connected to Neo4j 4.1.0 at neo4j://localhost:7687 as user neo4j.
Type :help for a list of available commands or :exit to exit the shell.
Note that Cypher queries must end with a semicolon.
```

than create .rbenv-vars

```
vi premesti.se/.rbenv-vars
# paste all secrets like
# SECRET_KEY_BASE=82e3f4asd...
# NEO4J_URL=http://neo4j:password@localhost:7687
## for low memory use:
# NODE_OPTIONS=--max-old-space-size=460
```

# Etc configurations: Monit, logrotate

Files that are used for `/etc` on server are stored inside `config/etc` in our
repository. They needs to be sym linked so we keep all configuration inside a
code.
Monit configuration files are stored in `config/etc/monit/conf-enabled` folder
which includes other files. For smtp we need to use gmail password so that
configuration is manually created on server in `premesti.se/.monit_mailserver`
(along with `premesti.se/.rbenv-vars`) so we do not store password in a code.

```
vi ~/premesti.se/.monit_mailserver
set mailserver
  smtp.gmail.com port 587
  username premesti.se@gmail.com password <GMAIL_PASSWORD>
  using tlsv13
```

To enable monit we need to link to our configuration

```
sudo ls /etc/monit/conf-enabled
# there should not be any files or links
sudo ln -s /home/ubuntu/premesti.se/current/config/etc/monit/conf-enabled/staging-app /etc/monit/conf-enabled
```

You can restart service
```
sudo service monit force-reload
```
and check configuration with verbose option
```
sudo monit -v
sudo monit summary
sudo monit status
sudo monit stop delayed_job_0
sudo monit unmonitor delayed_job_0
```
Watch logs and monit webserver using
```
bin/upload.sh staging-app -tunel
tail -f premesti.se/current/log/monit.log
```
and open the browser on http://localhost:8812

Enable logrotate
```
sudo ln -s /home/ubuntu/premesti.se/current/config/etc/logrotate.d/premesti.se /etc/logrotate.d/
```

Delay times total is 90 seconds (1min and 30s)
* 45-50 seconds to boot the machine (`tail -f premesti.se/current/log/monit.log`
  look for stopped and starting events) curl will respoond with Failed to
  connect: Connection refused
* premesti.se puma 40 seconds (we set start delay in monit, next check is after 60
  seconds), curl will respond with 502 Bad Gateway

Check if delayed jobs works
```
bin/upload.sh staging-worker -ssh
sudo monit summary
tail premesti.se/current/log/monit.log
tail premesti.se/current/log/delayed_job.log
```

# Steps specific to app server

To provision app server run same as above (just replace `_worker` with `_app`)
and than install nginx.

```
sudo apt install -y nginx
```
You should see nginx page on http://premesti.se.com/

Use copy instead of link puma startup script (since there is a warning
*Warning: The unit file, source configuration file or drop-ins of puma.service
changed on disk. Run 'systemctl daemon-reload' to reload units.*)
Link nginx configuration.
```
# sudo ln -s /home/ubuntu/premesti.se/current/config/etc/systemd/system/puma.service /etc/systemd/system
sudo cp /home/ubuntu/premesti.se/current/config/etc/systemd/system/puma.service /etc/systemd/system

sudo systemctl daemon-reload
sudo systemctl enable puma.service

sudo ls -l /etc/nginx/sites-enabled
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /home/ubuntu/premesti.se/current/config/etc/nginx/sites-enabled/nginx_puma /etc/nginx/sites-enabled
```

Test and watch logs

```
tail -f /var/log/nginx/*
tail -f premesti.se/current/log/*
sudo service puma status
sudo service puma stop
sudo service puma start
```

Update domain with you domain that points to staging IP address
```
host premesti.se.trk.in.rs
# premesti.se.trk.in.rs has address 13.250.12.234
```

# Move your place

<a href='https://en-premesti-se.trk.in.rs'>TRK Premesti Se</a> is a site for
communication between parents when they want to switch places in kindergartens.

## Getting Started

You can download and run the project locally to see how it works.
In source you can see usage of the:

* Rails 5
* Neo4j database
* yarn installed: bootstrap 4, jquery 3, font awesome 4, snapsvg, select2
* svg animations and animate.css
* sidekiq
* redis for sidekiq, cache store, action cable
* chat with ActionCable
* test with minitests, headless chrome
* sign up with facebook, google and email
* ssl is enabled using free cloudflare https and lets encrypt

Graph database is chosen since we need to store movement wishes like A->B, A->C,
C->D, D->A and we want to find all matches like A->C->D->A.

## Neo4j Database

It runs on Java 8 so download Java SDK from Oracle.
To install Neo4j use this rails tasks
https://github.com/neo4jrb/neo4j-rake_tasks

~~~
rails neo4j:install[community-latest,development]
rails neo4j:install[community-latest,test]

## this will change in db/neo4j/development/conf/neo4j.conf
## dbms.connector.http.listen_address=localhost:7042
rails neo4j:config[development,$NEO4J_PORT]
# also for test
rails neo4j:config[test,$NEO4J_TEST_PORT]
~~~

Stop neo4j servers
```
rails neo4j:stop[development]
# or using cli
db/neo4j/development/bin/neo4j stop

# also for test
rails neo4j:stop[test]
```

Start neo4j server with:

~~~
rails neo4j:start[development]
xdg-open http://localhost:7042/browser/
rails neo4j:start[test]
xdg-open http://localhost:7047/

tail -f db/neo4j/development/logs/*
~~~

Note that when you are changing the ports, then run `spring stop` to reload new
env.

If you receive an error `ERROR! Neo4j cannot be started using java version
11.0.8.` than you can use older java on ubuntu with command:
```
sudo update-alternatives --config java
```


Drop migrate and seed with custom rake tasks.

~~~
rake db:drop
rake db:migrate
rake db:seed
~~~

For test you need to run migration also

~~~
RAILS_ENV=test rake db:migrate
# this will actually run
RAILS_ENV=test rake neo4j:migrate
~~~

You can also run neo4j from default ubuntu software, it's config is located at
`/etc/neo4j/neo4j.conf` and database folder is
`/var/lib/neo4j/data/databases/graph.db`
and you need to set port

```
sudo neo4j start
export NEO4J_PORT=7474
```

## Run

Before running localy you need to get npm packages with:

~~~
npm install
~~~

Look at config/secrets.yml for env that you need to export

```
export NEO4J_TYPE=http
export NEO4J_URL=http://neo4j:password@localhost:7042
```
and start the server
```
rails s
```

and open browser at <http://localhost:3000>

To run background jobs you need redis server running. Note than we renamed
default queue names which you can find in `config/sidekiq.yml`

~~~
sidekiq
~~~

and open browser <http://localhost:3000/sidekiq>

## Locale

Serbian cyrillic is default. When you add new items in one language, you can
automatically translate to other (from cyrillic to latin and en) with rake tasks

~~~
rails translate:missing
rails translate:copy
~~~

For hard coded string you can use helper

~~~
'my string'.to_cyr
 => "мy стринг"
~~~

or from
[yml_google_translate_api](https://github.com/duleorlovic/config/blob/master/bin/yml_google_translate_api.rb)

```
yml_google_translate_api.rb config/locales/sr-latin.yml  sr_to_cyr en
```

## Mails

We send several type of mails. You can see them
<http://localhost:3000/rails/mailers>

## Test

Run test with

~~~
bin/rails test
bin/rails test:system
guard
~~~

If guard or test runner does not see `<class:Application>': Please set env
variables for NEO4J server ://:@: (RuntimeError)` than `spring stop` can help.

You can pause test with `byebug` and open neo4j <http://localhost:7047/browser/>

## Production

It is currently deployed to my computer using capistrano 3.

```
cap production deploy
```

To see logs you can inspect

```
tail -f /var/log/nginx/* ~/premesti.se/current/log/*
```

When you update a blog pages than you need to build and commit changes

```
cd blog
jekyll s
```

To dump you can use the script

```
bin/dump_db.sh
```

## Staging

Staging can be deployed to Heroku using free services. For graph database I use
my own hosting since GrapheneDB has very low limit for free tier.
Since we are using npm, we need to add buildpack

```
heroku buildpacks:set https://github.com/heroku/heroku-buildpack-ruby
heroku buildpacks:add --index 1 https://github.com/heroku/heroku-buildpack-nodejs
```
To dump from GrapheneDB and restore locally

~~~
rm -rf db/neo4j/development/data/databases/graph.db
mkdir db/neo4j/development/data/databases/graph.db
unzip tmp/graphdb.zip -d db/neo4j/development/data/databases/graph.db
rails neo4j:restart[development]
rake neo4j:migrate
~~~

Cloudflare points directly on https herokuapp.
Use root domain `@` and `www`, `en` and `sr-latin` domain to point to herokuappp
```
CNAME premesti.se is an alias of premesti-se.herokuapp.com
CNAME www is an alias of premesti-se.herokuapp.com
CNAME en is an alias of premesti-se.herokuapp.com
CNAME sr-latin is an alias of premesti-se.herokuapp.com
```
On Crypto tab on Cloud Flare select FULL (not Flexible) SSL and check the Always use HTTPS.
On Page rules add redirect non www to www.

~~~
https://premesti.se/* -> https://www.premesti.se/$1
~~~

## New school year

On 01.09 every year we need to increase age. But since first results of
applications are in June, we can show two messages.
* from June to August: instead of `Mlađa jaslena` we use `od septembra Starija jaslena`
* from Sep to May: we show `Starija jaslena`
Do not need to create new groups for age 1 since we use
`Group.find_or_create_by_location_id_and_age`.
We need to destroy moves for kids that are older than 7.
So all we need is to run this commands on September 1st:

~~~
Location.all.each {|l| l.groups.query_as(:g).order('g.age DESC').pluck(:g).map { |g| g.age += 1; g.save! } }
Move.all.select {|m| m.from_group.age>7}.map {|m| m.destroy_and_archive_chats :end_of_kindergarten}
~~~

## Contributing

Bug reports and pull requests are welcome on GitHub at
[github.com/trkin/premesti.se/issues].
Thank you [contributors]!

[github.com/trkin/premesti.se/issues]: https://github.com/trkin/premesti.se/issues
[contributors]: https://github.com/trkin/premesti.se/graphs/contributors

## License

The project is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

## Authors

This project is designed and created by
[duleorlovic](https://github.com/duleorlovic/)

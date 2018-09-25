# Move your place

<a href="http;//www.premesti.se">Premesti.Se</a> is a site for communications
between parents when they want to switch places in kindergartens.

## Getting Started

You can download and run the project locally to see how it works.
In source you can see usage of the:

* Rails 5
* Neo4j database
* yarn installed: bootstrap 3, jquery 3, font awesome 4, snapsvg, select2
* svg animations
* sidekiq
* redis for sidekiq, cache store, action cable
* chat with ActionCable
* test with minitests, headless chrome
* sign up with facebook, google and email

Graph database is chosen since we need to match moves in format A->B, B->A
(I want to move from A to B, so please find me who wants to move from B to A).
But there is also trio variant; A->B, B->C and C->A.

## Neo4j Database

It runs on Java 8 so download Java SDK from Oracle.
To install Neo4j use this rails tasks

~~~
rails neo4j:install[community-latest,development]
rails neo4j:install[community-latest,test]

## this will change db/neo4j/development/conf/neo4j.conf
rails neo4j:config[development,$(expr $NEO4J_PORT + 2)]
rails neo4j:config[test,$(expr $NEO4J_TEST_PORT + 2)]
~~~

Start neo4j server with:

~~~
rails neo4j:start[development]
gnome-open http://localhost:$(expr $NEO4J_PORT + 2) # http://localhost:7042/browser/
rails neo4j:start[test]
gnome-open http://localhost:$(expr $NEO4J_TEST_PORT + 2) # http://localhost:7047/
~~~

Note that when you are changing the ports, then run `spring stop` to reload new
env.

Drop migrate and seed with custom rake tasks.

~~~
rake db:drop
rake db:migrate
rake db:seed
~~~

For test you need to do again

~~~
RAILS_ENV=test rake db:migrate
~~~

## Run

Before running localy you need to get npm packages with:

~~~
yarn install
~~~

Than run as usual

~~~
rails s
~~~

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

and you can use helper

~~~
'my string'.to_cyr
 => "мy стринг"
~~~

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

It is currently deployed to Heroku using free services.
To dump from GrapheneDB and restore locally

~~~
rm -rf db/neo4j/development/data/databases/graph.db
mkdir db/neo4j/development/data/databases/graph.db
unzip tmp/graphdb.zip -d db/neo4j/development/data/databases/graph.db
rails neo4j:restart[development]
rake neo4j:migrate
~~~

## New school year

On 01.09 every year we need to increase age. Do not need to create new groups
for age 1 since we use `Group.find_or_create_by_location_id_and_age`.
We need to destoy moves for kids that are older than 7.

~~~
Location.all.each {|l| l.groups.query_as(:g).order('g.age DESC').pluck(:g).map { |g| g.age += 1; g.save! } }
Move.all.select {|m| m.from_group.age>7}.map {|m| m.destroy_and_archive_chats :end_of_kindergarten}
~~~

## Contributing

Bug reports and pull requests are welcome on GitHub at
[github.com/duleorlovic/premesti.se/issues].
Thank you [contributors]!

[github.com/duleorlovic/premesti.se/issues]: https://github.com/duleorlovic/premesti.se/issues
[contributors]: https://github.com/duleorlovic/premesti.se/graphs/contributors

## License

The project is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

## Authors

This project is designed and created at TRK INNOVATIONS LLC by:

* [duleorlovic](https://github.com/duleorlovic)

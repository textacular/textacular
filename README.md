# textacular

Further documentation available at http://textacular.github.com/textacular.


## DESCRIPTION:

Textacular exposes full text search capabilities from PostgreSQL,
extending ActiveRecord with scopes making search easy and fun!


## FEATURES/PROBLEMS:

* Only works with PostgreSQL
* Anything that mucks with the `SELECT` statement (notably `pluck`), is likely
  to [cause problems](https://github.com/textacular/textacular/issues/28).


## SYNOPSIS:

### Quick Start

#### Rails 3 (or 4!)

In the project's Gemfile add

```ruby
gem 'textacular', '~> 3.0'
```

#### ActiveRecord outside of Rails

```ruby
require 'textacular'

ActiveRecord::Base.extend(Textacular)
```


### Usage

Your models now have access to search methods:

The `#basic_search` method is what you might expect: it looks literally for what
you send to it, doing nothing fancy with the input:

```ruby
Game.basic_search('Sonic') # will search through the model's :string columns
Game.basic_search(title: 'Mario', system: 'Nintendo')
```

The `#advanced_search` method lets you use Postgres's search syntax like '|',
'&' and '!' ('or', 'and', and 'not') as well as some other craziness. Check [the
Postgres
docs](http://www.postgresql.org/docs/9.2/static/datatype-textsearch.html) for more:

```ruby
Game.advanced_search(title: 'Street|Fantasy')
Game.advanced_search(system: '!PS2')
```

Finally, the `#fuzzy_search` method lets you use Postgres's trigram search
funcionality.

In order to use this, you'll need to make sure your database has the `pg_trgm`
module installed. On your development machine, you can `require textacular/tasks` and run

```
rake textacular:install_trigram
```

Depending on your production environment, you might be able to use the rake
task, or you might have to manually run a command. For Postgres 9.1 and above,
you'll want to run

```sql
CREATE EXTENSION pg_trgm;
```

Once that's installed, you can use it like this:

```ruby
Comic.fuzzy_search(title: 'Questio') # matches Questionable Content
```

Searches are also chainable:

```ruby
Game.fuzzy_search(title: 'tree').basic_search(system: 'SNES')
```

If you want to search on two or more fields with the OR operator use a hash for
the conditions and pass false as the second parameter:

```ruby
Game.basic_search({name: 'Mario', nickname: 'Mario'}, false)
```


### Setting Language

To set proper searching dictionary just override class method on your model:

```ruby
def self.searchable_language
  'russian'
end
```

And all your queries would go right! And don`t forget to change the migration for indexes, like shown below.


### Creating Indexes for Super Speed
You can have Postgresql use an index for the full-text search.  To declare a full-text index, in a
migration add code like the following:

```ruby
execute "
    create index on email_logs using gin(to_tsvector('english', subject));
    create index on email_logs using gin(to_tsvector('english', email_address));"
```

In the above example, the table email_logs has two text columns that we search against, subject and email_address.
You will need to add an index for every text/string column you query against, or else Postgresql will revert to a
full table scan instead of using the indexes.

If you create these indexes, you should also switch to sql for your schema_format in `config/application.rb`:

```ruby
config.active_record.schema_format = :sql
```


## REQUIREMENTS:

* ActiveRecord
* Ruby 1.9.2


## INSTALL:

```
$ gem install textacular
```

## Contributing

Help is gladly welcomed. If you have a feature you'd like to add, it's much more
likely to get in (or get in faster) the closer you stick to these steps:

1. Open an Issue to talk about it. We can discuss whether it's the right
  direction or maybe help track down a bug, etc.
1. Fork the project, and make a branch to work on your feature/fix. Master is
  where you'll want to start from.
1. Write a test for the feature you are about to add
1. Run the tests
1. Turn the Issue into a Pull Request. There are several ways to do this, but
  [hub](https://github.com/defunkt/hub) is probably the easiest.
1. Bonus points if your Pull Request updates `CHANGES.md` to include a summary
   of your changes and your name like the other entries. If the last entry is
   the last release, add a new `## Unreleased` heading.

If you don't know how to fix something, even just a Pull Request that includes a
failing test can be helpful. If in doubt, make an Issue to discuss.

## LICENSE:

(The MIT License)

Copyright (c) 2011 Aaron Patterson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

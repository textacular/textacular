# textacular
[![Gem Version](http://img.shields.io/gem/v/textacular.svg)][rubygems]
[![Build Status](https://img.shields.io/travis/textacular/textacular/master.svg)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/textacular/textacular.svg)][codeclimate]

[rubygems]: http://rubygems.org/gems/textacular
[travis]: https://travis-ci.org/textacular/textacular
[codeclimate]: https://codeclimate.com/github/textacular/textacular

Further documentation available at http://textacular.github.com/textacular.


## DESCRIPTION:

Textacular exposes full text search capabilities from PostgreSQL,
extending ActiveRecord with scopes making search easy and fun!


## FEATURES/PROBLEMS:

* Only works with PostgreSQL


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
'&' and '!' ('or', 'and', and 'not') as well as some other craziness. The ideal
use for advanced_search is to take a search DSL you make up for your users and
translate it to PG's syntax. If for some reason you want to put user input
directly into an advanced search, you should be sure to catch exceptions from
syntax errors. Check [the Postgres docs]
(http://www.postgresql.org/docs/9.2/static/datatype-textsearch.html) for more:

```ruby
Game.advanced_search(title: 'Street|Fantasy')
Game.advanced_search(system: '!PS2')
```

Finally, the `#fuzzy_search` method lets you use Postgres's trigram search
functionality.

In order to use this, you'll need to make sure your database has the `pg_trgm`
module installed. Create and run a migration to install the module:

```
rake textacular:create_trigram_migration
rake db:migrate
```

Once that's installed, you can use it like this:

```ruby
Comic.fuzzy_search(title: 'Questio') # matches Questionable Content
```

Note that fuzzy searches are subject to a similarity threshold imposed by the `pg_trgm` module. The default is 0.3, meaning that at least 30% of the total string must match your search content. For example:

```ruby
Comic.fuzzy_search(title: 'Pearls') # matches Pearls Before Swine
Comic.fuzzy_search(title: 'Pear') # does not match Pearls Before Swine
```

The similarity threshold is hardcoded in PostgreSQL and can be modified on a per-connection basis, for example:

```ruby
ActiveRecord::Base.connection.execute("SELECT set_limit(0.9);")
```

For more info, view the `pg_trgm` documentation, specifically [F.35.2. Functions and Operators](http://www.postgresql.org/docs/9.1/static/pgtrgm.html).

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

If you'd like to contribute, please see the [contribution guidelines](CONTRIBUTING.md).


## Releasing

Maintainers: Please make sure to follow the [release steps](RELEASING.md) when
it's time to cut a new release.


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

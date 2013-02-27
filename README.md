# textacular

Further documentation available at http://textacular.github.com/textacular.


## DESCRIPTION:

Textacular exposes full text search capabilities from PostgreSQL,
extending ActiveRecord with scopes making search easy and fun!


## FEATURES/PROBLEMS:

* Only works with PostgreSQL


## SYNOPSIS:

### Quick Start

#### Rails 3

In the project's Gemfile add

    gem 'textacular', '~> 2.0', require: 'textacular/rails'


#### ActiveRecord outside of Rails 3

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
funcionality:

```ruby
Comic.fuzzy_search(title: 'Questio') # matches Questionable Content
```

Searches are also chainable:

```ruby
Game.fuzzy_search(title: 'tree').basic_search(system: 'SNES')
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

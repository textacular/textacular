# Change Log

## Unreleased

## 3.2.2

* Fallback to zero similarity when trying to match null values
* Fix search term escaping
* Trigram installation migration only install extension if not installed yet.
* Update the README to illustrate how to change the similarity threshold.

## 3.2.1

* Fix trigram installation migration reversed filename and content.
* Rewrite all tests using RSpec.
* We're ActiveRecord 4.2+ compatible until tests prove otherwise.

## 3.2.0

* Add generator for trigram installation migration.
* Expand gemspec to allow newest version of ActiveRecord.

## 3.1.0

* Avoid Deprecation warnings from ActiveRecord 4.0.0.rc2.
* Fix `method_missing` in ActiveRecord 4.0.0.rc2.
* Remove unused `Textacular#normalize` method.
* Add `OR` example to the README.
* Fix tests for Ruby 2.0.0 & related improvements.
* Improve Rails integration.
* Fix dependency loading for textacular rake tasks.
* Fix ranking failures when rows had `NULL` column values.
* Clean up Rakefile; should make developing the gem nicer.
* DEPRECATION: The dynamic search helpers will be removed at the next major
  release.

## 3.0.0

* All deprecations have been resolved. This breaks backwards compatibility.
* Rename gem to Textacular.

## 2.2.0

* 1 DEPRECATION
  * The whole gem is being renamed and will no longer be maintained as Texticle.
    The new name it Textacular.
* 1 new feature
  * Expand gemspec to allow Rails 4.

## 2.1.1

* 1 bugfix
  * Include `lib/textacular/version.rb` in the gemspec so the gem will load. Sorry!


## 2.1.0

* 1 DEPRECATION
  * `search` aliases new `advanced_search` method (same functionality as before), but will
    alias `basic_search` in 3.0! Should print warnings.
* 3 new features
  * Generate full text search indexes from a rake task (sort of like in 1.x). Supply a specific
    model name.
  * New search methods: `basic_search`, `advanced_search` and `fuzzy_search`. Basic allows special
    characters like &, and % in search terms. Fuzzy is based on Postgres's trigram matching extension
    pg_trgm. Advanced is the same functionality from `search` previously.
  * Rake task that installs pg_trgm now works on Postgres 9.1 and up.
* 2 dev improvements
  * Test database configuration not automatically generated from a rake task and ignored by git.
  * New interactive developer console (powered by pry).


## 2.0.3

* 1 new feature
  * Allow searching through relations. Model.join(:relation).search(:relation => {:column => "query"})
    works, and reduces the need for multi-model tables. Huge thanks to Ben Hamill for the pull request.
  * Allow searching through all model columns irrespective of the column's type; we cast all columns to text
    in the search query. Performance may degrade when searching through anything but a string column.
* 2 bugfixes
  * Fix exceptions when adding Textacular to a table-less model.
  * Column names in a search query are now scoped to the current table.
* 1 dev improvement
  * Running `rake` from the project root will setup the test environment by creating a test database
    and running the necessary migrations. `rake` can also be used to run all the project tests.


## 2.0.2

* 1 bugfix
  * Our #respond_to? overwritten method was causing failures when a model didn't have
    a table (e.g. if migrations hadn't been run yet). Not the case anymore.


## 2.0.1

* 1 new feature
  * Can now define #searchable_language to specify the language used for the query. This changes
    what's considered a stop word on Postgres' side. 'english' is the default language.
* 1 bugfix
  * We were only specifying a language in to_tsvector() and not in to_tsquery(), which could
    cause queries to fail if the default database language wasn't set to 'english'.


## 2.0.pre4

* 1 new feature
  * Searchable is now available to specify which columns you want searched:

      ```ruby
      require 'textacular/searchable'
      class Game
        extend Searchable(:title)
      end
      ```

      This also allows Textacular use in Rails without having #search available to all models:

      ```
      gem 'textacular', '~> 2.0.pre4', :require => 'textacular/searchable'
      ```
* 1 bugfix
  * ActiveRecord::Base.extend(Textacular) doesn't break #method_missing and #respond_to? anymore


## 2.0.pre3

* 1 new feature
  * #select calls now limit the columns that are searched
* 1 bugfix
  * #search calls without an argument assume an empty string as a search term (it errored out previously)


## 2.0.pre2

* 1 bugfix
  * #respond_to? wasn't overwritten correctly

## 2.0.pre

* Complete refactoring of Textacular
  * For users:
    * Textacular should only be used for its simplicity; if you need to deeply configure your text search, please give `gem install pg_search` a try.
    * `#search` method is now included in all ActiveRecord models by default, and searches across a model's :string columns.
    * `#search_by_<column>` dynamic methods are now available.
    * `#search` can now be chained; `Game.search_by_title("Street Fighter").search_by_system("PS3")` works.
    * `#search` now accepts a hash to specify columns to be searched, e.g. `Game.search(:name => "Mario")`
    * No more access to `#rank` values for results (though they're still ordered by rank).
    * No way to give different weights to different columns in this release.
  * For devs:
    * We now have actual tests to run against; this will make accepting pull requests much more enjoyable.


## HEAD (unreleased)

* 1 minor bugfix
  * Multiple named indices are now supported.


## 1.0.4 / 2010-08-19

* 2 major enhancements
  * use Rails.root instead of RAILS_ROOT
  * refactored tasks to ease maintainance and patchability
* 3 minor enhancements
  * fix timestamp for migrationfile
  * fixed deprecation warning for rails3 (dropping rails2-support)
  * prevented warning about defined constant


## 1.0.3 / 2010-07-07

* 1 major enhancement
  * Added Rails 3 support.
* 1 bugfix
  * Model names that end in double 's's (like Address) don't choke the rake tasks anymore.


## 1.0.2 / 2009-10-17

* 1 bugfix
  * Generated migration now uses UTC time rather than local time.


## 1.0.1 / 2009-04-14

* 1 minor enhancement
  * Textical adds a rake task to generate FTS index migrations.  Just run:

      ```
      rake textical:migration
      ```


## 1.0.0 / 2009-04-14

* 1 major enhancement
  * Birthday!

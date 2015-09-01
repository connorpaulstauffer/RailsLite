# RailsLite

## Concept
RailsLite is a web server MVC framework inspired by the functionality of Rails complete
with an ORM inspired by ActiveRecord.

## Features
 * Utilizes WEBrick as an HTTP web server
 * ORM
   * Associations
     * belongs_to
     * has_many
     * has_one_through
   * [Searchable][searchable] module with Searchable#where method that handles
   multiple conditions
 * Base controller class
   * Generates, saves, and validates form authenticity tokens
   * Utilizes metaprogramming to call appropriate action
 * Flash class supports message generation on render and redirect
 * Params class implements custom recursive my_deep_merge method to combine
 router URL params, query string params, and request body params
 * Router class uses Regex to route url inputs to corresponding controller actions
 * Session class stores cookies in browser to support session persistence
 * Views utilize embedded ruby to generate html dynamically

## Instructions
To run RailsLite, clone this repository into a local directory. ```cd``` into
the directory. Run ```bundle install```. Start the server with
```ruby bin/server.rb``` and navigate to localhost:3000/cats in your browser.

To customize the application, alter the sql script in [cats.sql][sql], or the
models or controllers in [server.rb][server].

[sql]: ./cats.sql
[server]: ./bin/server.rb

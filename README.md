A very initial active_record intergration for OpenSearchServer http://www.open-search-server.com

This is very very initial, no tests yet, but there is a running dummy application

Depends on OriPekelman/oss_rb

## Installation

Add this line to your application's Gemfile:

    gem 'oss_rb', :github => "OriPekelman/oss_rb"
    gem 'oss_active_record', :github => "OriPekelman/oss_active_record"
    

And then execute:

    $ bundle

Or install it yourself as (not on rubygems yet!):

    $ gem install oss_active_record

## Configuration
Add `config/initializers/oss_active_record.rb` with the url of opens-search-server

	Rails.configuration.open_search_server_url = "http://localhost:8080"

## Usage


```ruby
class Person < ActiveRecord::Base
  searchable do
    integer  :id
    integer  :age
    text     :name              # fulltext
    string   :name              # order_by
    time     :updated_at
  end
end
```
Records are autonindexed by default.

You can search by example:

```ruby
result = Person.search do
	fulltext 'john'
	with :age, 20
	paginate page: 1, per_page: 10
	order_by :score, :desc
	order_by :id, :asc
end
@result.each { |person| puts person }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request




Compare book prices across Indian ecommerce sites.

Parsing code based on Swaroop's isbn.net.in code - https://github.com/swaroopch/isbnnetin

Worker
------

```ruby
VERBOSE=1 QUEUE=fetch bundle exec rake resque:start
```

Server
------

```ruby
bundle exec ruby app.rb -sv -e production
```

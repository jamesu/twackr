# Twackr
## What is it?

Simply put, Twackr is [twitter][1]-style time tracking. At its simplest, it's a tweet with a timer attached to it.

Tracked time can be categorised into @projects and #services. In addition to the basic timer, there are also numerous options for specifying time spent.

## How can i install / upgrade?

Simply run something like the following:

	export SESSION_SECRET=randomgarbagehere
	export DATABASE_URL=sqlite3://db/my_database.sqlite3
	rake db:migrate
	rackup -p 9000

And create a user. It couldn't be any simpler!

## Licensing

For licensing details, refer to the [LICENSE] [2] file in the root directory.

[1]: http://www.twitter.com
[2]: LICENSE


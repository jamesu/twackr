# Twackr
## What is it?

Simply put, Twackr is [twitter][1]-style time tracking. At its simplest, it's a tweet with a timer attached to it.

Tracked time can be categorised into @projects and #services. In addition to the basic timer, there are also numerous options for specifying time spent.

## How can i install / upgrade?

Simply run the following:

    rake db:auto:migrate
	script/server

And create a user. It couldn't be any simpler!

## Are there any screenshots or is there even a demo?

Please refer to the project entry on [OpenSourceRails] [3] for any screenshots.

A demo is [available on heroku][4].

## Can I run Twackr on Heroku?

Yes you can! And this is how:

1. Setup heroku app

    heroku create

2. Migrate database on heroku

    heroku db:auto:migrate

3. Launch in browser

    heroku open

## Licensing

For licensing details, refer to the [LICENSE] [2] file in the root directory.

[1]: http://www.twitter.com
[2]: LICENSE
[3]: http://www.opensourcerails.com
[4]: http://twackr.heroku.com/


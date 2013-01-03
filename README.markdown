Orchestrated Test Project
=========================

An application for testing the ```orchestrated``` Ruby Gem.

Installing The Toy Application
------------------------------

1. clone the repository: in your local terminal type
    ```git clone https://github.com/paydici/orchestrated_app.git```
2. install Ruby Gems
    ```bundle install```
3. set up the sqlite3 database:
    ```rake db:migrate```
4. run the specs (tests):
    ```rake spec```

If you did that right, you should see a bunch of green dots!

Playing With The Framework
--------------------------

If you run "rails s" and load the main page (/) you'll be creating a simple workflow. If you want to execute that thing you can either run ```rake jobs:work``` from the command line (to continually run steps) or go into ```rails c``` and run ```DJ.work(num=100)``` (to run a specified number of steps).

A great way to learn about the framework is to have a look at the specs (in the ```/spec``` directory).

See [orchestrated](https://github.com/paydici/orchestrated) for more information.

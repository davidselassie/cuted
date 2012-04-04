Cuted
====

Cuted is a very simple, single-machine, batch scheduler written in Ruby. I often want to queue up some commands that will each take a few hours to run, but I don't want to keep track of which ones are already running and don't want them all running simultaneously. Bash jobs can't let me do both of those things.

And it's a pun on queue.

Requirements
------------------
* Ruby 1.9.0+
* A few Gems:
	- [Trollop](http://trollop.rubyforge.org/)
	- [Parseconfig](http://www.5dollarwhitebox.org/drupal/?q=node/21)
	- [Daemons](http://daemons.rubyforge.org/)
	- [Prowler](http://rubydoc.info/gems/prowler/1.3.1/frames) (optional; for [Prowl](http://www.prowlapp.com/) notifications)

Usage
-------
There are two commands `cuted`, the scheduler daemon, and `cute` the queueing command.

You can start the scheduler by running `cuted start`. This will start the scheduling daemon in the background.

Then you can queue a command to run in the current working directory with `cute ANY COMMAND`. By default, the command's output and error are appended to a file `cuted.log` in that working directory.

You can stop the schdeuler with `cuted stop` and you can run it in the foreground, so it shows what tasks are in progress, with `cuted run`.

Scheduler Configuration
------------------------------
You can configure the scheduler by setting options in `~/.cuterc` file. Here are the defaults:

* `max_concurrent = 4`
How many commands are allowed to run at once.

* `log = cuted.log`
Wheither to append the output and error of the command to `cuted.log`.

* `uri = drbunix:///tmp/cuted.socket`
Where the server opens a pipe to recieve commands.

* `prowl_key = nil`
What Prowl key should be notified upon command completion. If the environment variable `PROWLKEY` is set, that is used.

Queueing Options
----------------------
There are some command line options for `cute`.

* `--dir`
Which working directory this command will run in. Defaults to the current.

* `--weight`
How many commands does this command count for. Defaults to 1. Since the scheduler defaults to a maximum of 4 simultaneous commands, if you submit some with `--weight 2` only two will run at a time.

* `--log`
A custom log to use for just this command.

* `--prowl-key`
A custom Prowl key to notify upon completion of just this command.

* `--uri`
Which pipe (and server) to write commands to. This option defaults to `drbunix:///tmp/cuted.sock` but will use the value of the environment variable `cuted_uri` if set (which the scheduler will write), or will use the path passed on the command line.

Caveats
---------
This is a pretty simple beast and does not currently:

* Reorder commands so as close to `max_concurrent` are running simultaneously. If you queue three 1-count tasks and one 4-count task with `max_concurrent = 4`, the first three will run and then the 4-count task will begin once the others have completed.

* This is a single-user system; all commands are run as the user who started `cuted`.

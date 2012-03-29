Cuted
====

Cuted is a very simple (and stupid), single-machine, batch scheduler written in Ruby. I often want to queue up some commands that will each take a few hours to run, but I don't want to keep track of which ones are already running and don't want them all running simultaneously. Bash jobs can't let me do both of those things.

Requirements
------------------
* Ruby 1.9.0+
* A few Gems:
	- Trollop
	- Parseconfig
	- Daemons
	- Prowler (optional; for Prowl notifications)

Usage
-------
There are two commands `cuted`, the scheduler daemon, and `cute` the queueing command.

You can start the server by running `cuted start`. This will start the scheduling daemon in the background.

Then you can queue a command to run in the current working directory with `cute ANY COMMAND`. By default, the command's output and error are appended to a file `cute.log` in that working directory.

You can stop the schdeuler with `cuted stop` and you can run it in the foreground, so it shows what tasks are in progress, with `cuted run`.

Scheduler Configuration
------------------------------
You can configure the scheduler by setting options in `~/.cuterc` file. Here are the defaults:

* `max_concurrent = 4`
How many commands are allowed to run at once.

* `log = true`
Wheither to append the output and error of the command to `cuted.log`.

* `server_pipe = ~/.cuted.socket`
Where the server opens a pipe to recieve commands.

* `prowl_key = nil`
What Prowl key should be notified upon command completion. If the environment variable `PROWLKEY` is set, that is used.

Queueing Options
----------------------
There are some command line options for `cute`.

* `--dir`
Which working directory this command will run in. Defaults to the current.

* `--count`
How many commands does this count as. Defaults to 1. Since the scheduler defaults to a maximum of 4 simultaneous commands, if you submit some with `--count 2` only two will run at a time.

* `--pipe`
Which pipe (and server) to write commands to. This option defaults to `~/.cuted.sock` but will use the value of the environment variable `cuted_pipe` if set (which the scheduler will write), or will use the path passed on the command line.

Caveats
---------
This is a pretty simple beast and does not currently:

* Place any priority on commands; first-in-first-out.
* Reorder commands so as close to `max_concurrent` are running simultaneously. If you queue three 1-count tasks and one 4-count task with `max_concurrent = 4`, all will start and the "command count" will be 7.
* All Prowl notifications go to the same user. You can't specify per-command notifications.
* This is meant to be a single-user system.

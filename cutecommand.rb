#!/usr/bin/env ruby

# David Selassie
# March 29, 2012
# cutejob.rb

# Structure for holding a queued shell command.

class CuteCommand
  require 'drb'
  require 'fileutils'

  # Make sure the command is stored on the server.
  include DRbUndumped

  attr_accessor :dir, :cmd, :weight, :priority, :log, :prowl_key
  attr_reader :pid

  def initialize(cmd, opts = {})
    @cmd = cmd.to_s
    # If the options are set, use them; otherwise defaults.
    @dir = opts[:dir] || Dir.pwd
    # Since we can force opts[:log] to be nil, and we don't want the default.
    @log = opts.has_key?(:log) ? opts[:log] : 'cute.log'
    @priority = opts[:priority] || 0
    @weight = opts[:weight] || 1
  end

  # Runs in the current thread.
  def run
    # Make sure the desired working directory exists.
    FileUtils.makedirs(@dir) if not File.directory?(@dir)
    # Actually run the command.
    if @log then
      @pid = spawn(@cmd, :chdir => @dir, [:out, :err] => [@log, 'a'])
    else
      @pid = spawn(@cmd, :chdir => @dir, [:out, :err] => '/dev/null')
    end

    # In the forked process, wait for the command to be done.
    Process.waitall

    # Report that this command finished.
    begin
      require 'prowler'
      Prowler.verify_certificate = false
      Prowler.application = 'cuted'
      Prowler.notify(@cmd, "Finished in #{@dir}", @prowl_key) if @prowl_key
    rescue LoadError
    end

    # Return the CuteCommand.
    self
  end

  # Print out dir> command string.
  def to_s
    "#{@dir}> #{@cmd}"
  end
end

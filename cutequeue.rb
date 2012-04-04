#!/usr/bin/env ruby

# David Selassie
# March 29, 2012
# cutequeue.rb

# Priority command queue.

class CuteQueue
  attr_accessor :running, :queue

  def initialize(opts = {})
    @queue = []
    @running = []

    # If the options are set, then use them; otherwise defaults.
    @defaults = opts[:defaults] || {}
    @max_concurrent = opts[:max_concurrent] || 4
    @logger = opts[:logger]
  end

  # Takes the text of a command or any structure that responds to :run.
  def push_cmd(cmd)
    @logger.info "Pushed command '#{cmd}'" if @logger

    # Really we just need a command to be able to run.
    if not cmd.respond_to?(:run)
      require_relative 'cutecommand'
      cmd = CuteCommand.new(cmd)
    end
    
    # Set up the command with the default values.
    @defaults.each do |k, v|
      cmd.send("#{k}=", v) if cmd.respond_to?("#{k}=")
    end

    @queue << cmd
    sort

    cmd
  end

  # Puts the highest priority commands first.
  def sort
    # If there is no priority, use 0.
    @queue.sort_by! { |cmd| cmd.respond_to?(:priority) ? -cmd.priority : 0 }

    self
  end

  # Return the highest priority command.
  def peek
    @queue[0]
  end

  # Find the highest priority item and run it.
  #  If continue is true, then run other commands in the queue when done.
  def pop_run(continue = true)
    # If there are no commands, do nothing.
    if @queue.length < 1 then
      @logger.info 'No commands to run' if @logger
      return
    # If there isn't enough free weight to run, do nothing.
    elsif peek.weight > @max_concurrent - @running.size and
        @running.size > 0 then
      @logger.info 'Not enough free weight to run' if @logger
      return
    end

    # Pop off the highest priority command.
    cmd = @queue.delete_at(0)
    sort

    # Run the command and return it.
    @logger.info "Starting #{cmd}" if @logger

    # Find out the weight of this command.
    weight = cmd.respond_to?(:weight) ? cmd.weight : 1
    # Add this command that many times to the running array.
    @running.concat([cmd] * weight)

    # In a separate thread...
    thread = Thread.new do
      # Run the command.
      cmd.run

      @logger.info "Finished #{cmd}" if @logger
      # Make the command remove itself from the running list.
      @running.delete_if { |o| o === cmd }
      # Try to run queued commands once this one is done if we're continuing.
      pop_run if continue
    end
  end

end

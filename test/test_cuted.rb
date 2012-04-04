#!/usr/bin/env ruby

# David Selassie
# April 2, 2012
# Cute unit tests. Checks CuteCommand and CuteQueue.

require 'riot'

context 'cuted/command' do
  require 'cuted/command'
  
  setup { Cuted::Command.new('echo hello') }

  context 'checking defaults' do
    asserts(:cmd).equals('echo hello')
    asserts(:dir).equals(Dir.pwd)
    asserts(:log).equals('cute.log')
    asserts(:pid).nil
  end

  context 'checking init' do
    setup do
      Cuted::Command.new('echo hello', :dir => '/tmp', :log => nil)
    end

    asserts(:cmd).equals('echo hello')
    asserts(:dir).equals('/tmp')
    asserts(:log).nil
  end

  context 'checking setters' do
    context 'cmd' do
      setup { topic.cmd = 'echo bye'; topic }
      asserts(:cmd).equals('echo bye')
    end

    context 'dir' do
      setup { topic.dir = '/tmp'; topic }
      asserts(:dir).equals('/tmp')
    end

    context 'log' do
      setup { topic.log = 'test.out'; topic }
      asserts(:log).equals('test.out')
    end    
  end

  context 'checking string' do
    setup do
      topic.dir = 'dir'
      topic.cmd = 'cmd'
      topic
    end

    asserts(:to_s).equals('dir> cmd')
  end
  
  context 'running' do
    setup { topic.run }

    denies(:pid).nil
  end

  context 'running with log' do
    setup do
      File.delete('/tmp/cute.log') if File.exists?('/tmp/cute.log')
      topic.dir = '/tmp'
      topic.log = 'cute.log'
      topic.run
    end

    should('find output in log') do
      File.new('/tmp/cute.log').read
    end.equals("hello\n")
  end
end

context 'cuted/queue' do
  require 'cuted/queue'
  require 'cuted/command'

  setup { Cuted::Queue.new(:cmd_defaults => {:log => nil})}

  context 'check init' do
    setup { Cuted::Queue.new }

    asserts(:queue).size(0)
    asserts(:running).size(0)
    asserts(:peek).nil
    asserts(:pop_run).nil
  end

  context 'checks command defaults' do
    setup do
      topic = Cuted::Queue.new(:defaults => {:log => 'deflog.out',
                              :weight => 2, :dir => '/tmp'})
      topic.push_cmd('echo default')
      topic
    end

    asserts('default log') { topic.peek.log }.equals('deflog.out')
    asserts('default weight') { topic.peek.weight }.equals(2)
    asserts('default dir') { topic.peek.dir }.equals('/tmp')
  end

  context 'adds a string command' do
    setup do
      topic.push_cmd('echo string')
      topic
    end

    asserts('command string') { topic.peek.cmd }.equals('echo string')
    asserts('has run') { topic.peek.respond_to?(:run) }
  end

  context 'adds a command' do
    setup do
      topic.push_cmd(Cuted::Command.new('echo hi1'))
      topic
    end

    asserts(:queue).size(1)
    asserts(:running).size(0)
    asserts('next command') { topic.peek.cmd }.equals('echo hi1')

    context 'and pops it' do
      setup do
        topic.pop_run
        sleep(1) # Wait for our simple process to finish.
        topic
      end

      asserts(:queue).size(0)
      asserts(:running).size(0)
      asserts(:peek).nil
      asserts(:pop_run).nil
    end
  end

  context 'adds two commands' do
    setup do
      topic.push_cmd(Cuted::Command.new('echo hi1', :priority => 1))
      topic.push_cmd(Cuted::Command.new('echo hi2', :priority => 2))
      topic
    end

    asserts(:queue).size(2)
    asserts(:running).size(0)
    asserts('next command') { topic.peek.cmd }.equals('echo hi2')

    context 'and pops higher priority' do
      setup do
        topic.pop_run(false)
        sleep(1) # Wait for our simple process to finish.
        topic
      end

      asserts(:queue).size(1)
      asserts(:running).size(0)
      asserts('next command') { topic.peek.cmd }.equals('echo hi1')

      context 'and pops lower priority' do
        setup do
          topic.pop_run(false)
          sleep(1) # Wait for our simple process to finish.
          topic
        end

        asserts(:queue).size(0)
        asserts(:running).size(0)
        asserts(:peek).nil
      end
    end
  end

end

RAILS_ROOT = ENV["RAILS_ROOT"] || File.expand_path(File.dirname(__FILE__))
RAILS_ENV  = ENV["RAILS_ENV"] || "development"
RAILS_PORT = ENV["RAILS_PORT"] || "4000"
FAYE_PORT  = ENV["FAYE_PORT"] || "9292"
USE_SYSLOG = ENV['RAILS_LOG_TO_SYSLOG'].present?

if USE_SYSLOG
  require 'syslog/logger'
end

WORKERS_COUNT=1

def puma_log
  if USE_SYSLOG
    #Syslog::Logger.new('sparc-request')
    ":syslog"
  else
    "log/puma.log"
  end
end

def dj_log(name)
  if USE_SYSLOG
    #Syslog::Logger.new('sparc-request-jobs')
    ":syslog"
  else
    "log/#{name}.log"
  end
end

def faye_log
  if USE_SYSLOG
    ":syslog"
  else
    "log/fulfillment_faye.stdall.log"
  end
end

def delayed_job_process(proxy, name)
  rails_env = proxy.env['RAILS_ENV']
  proxy.process(name) do
    start_command "bin/delayed_job -e #{rails_env} run"
    pid_file "tmp/pids/#{name}.pid"
    stdall dj_log(name)
    daemonize true
    stop_signals [:INT, 30.seconds, :TERM, 10.seconds, :KILL]
    check :cpu, every: 30, below: 80, times: 3
    check :memory, every: 30, below: 300.megabytes, times: 5
  end
end

Eye.config do
  if USE_SYSLOG
    logger syslog
  else
    logger "#{RAILS_ROOT}/log/eye.log"
  end
end

Eye.application 'fulfillment' do
  working_dir RAILS_ROOT
  env ({
    "PORT" => RAILS_PORT 
  })
  load_env ".env"
#  env 'APP_ENV' => 'production' # global env for each processes
  trigger :flapping, times: 10, within: 1.minute, retry_in: 10.minutes

  group 'web' do

    process :puma do
      daemonize true
      stdall puma_log
      pid_file "tmp/pids/puma.pid" # pid_path will be expanded with the working_dir
      start_command "bin/puma -p #{RAILS_PORT} -e #{RAILS_ENV}"
      stop_signals [:TERM, 5.seconds, :KILL]
      restart_command 'kill -USR2 {PID}'
      # when no stop_command or stop_signals, default stop is [:TERM, 0.5, :KILL]
      # default `restart` command is `stop; start`


      # ensure the CPU is below 30% at least 3 out of the last 5 times checked
      check :cpu, every: 30, below: 80, times: 3
    end

    process :faye do
      opts = [
        "-p #{FAYE_PORT}",
        "-P tmp/pids/fulfillment_faye_thin.pid",
        '-d',
        '-R faye.ru',
        "--tag fulfillment_faye_thin",
        '-t 30',
        "-e #{RAILS_ENV}",
        "-c #{RAILS_ROOT}",
        '-a 127.0.0.1'
      ]
      pid_file "tmp/pids/fulfillment_faye_thin.pid"
      start_command "bin/thin start #{opts * ' '}"
      stop_signals [:QUIT, 2.seconds, :TERM, 1.seconds, :KILL]
      stdall faye_log

    end
  end

  group 'jobs' do
    chain grace: 5.seconds
    (1..WORKERS_COUNT).each do |i|
      delayed_job_process self, "dj-#{i}"
    end
  end
end

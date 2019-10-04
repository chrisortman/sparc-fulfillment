namespace :mysql do
  desc 'execute a SQL command. Usage: rake db:execute SQL=""'
  task :execute => :environment do
    ActiveRecord::Base.establish_connection( (ENV['ENV'] || Rails.env).to_sym)
    ActiveRecord::Base.connection.execute( ENV['SQL'].to_s ).each { |hash| p hash }
  end

  desc 'Backup database by mysqldump'
  task :backup => :environment do
    directory = File.join(Rails.root, 'db', 'backup')
    FileUtils.mkdir directory unless File.exists?(directory)
    require 'yaml'
    db = YAML::load( File.open( File.join(Rails.root, 'config', 'database.yml') ) )[ Rails.env ]
    file = File.join( directory, "#{Rails.env}_#{DateTime.now.to_s}.sql" )
    p command = "mysqldump --opt --skip-add-locks -u #{db['username']} -p#{db['password']} -h #{db['host']} #{db['database']} | gzip > #{file}.gz"
    exec command
  end

  desc "restore most recent mysqldump (from db/backup/*.sql.*) into the current environment's database."
  task :restore => :environment do |name|
    unless Rails.env.development?
      puts "Are you sure you want to import into #{Rails.env}?! [y/N]"
      return unless STDIN.gets =~ /^y/i
    end

    db = YAML::load( File.open( File.join(Rails.root, 'config', 'database.yml') ) )[ Rails.env ]
    directory = File.join( Rails.root, 'db', 'backup')
    wildcard  = File.join( directory, ENV['FILE'] || "#{ENV['FROM']}*.sql.*" )
    puts file = `ls -t #{wildcard} | head -1`.chomp  # default to file, or most recent ENV['FROM'] or just plain most recent

    raise "No backup file found" unless File.exist?(file)

    puts "please wait, this may take a minute or two..."
    if file =~ /\.gz(ip)?$/
      exec "gunzip < #{file} | mysql  -u #{db['username']} -p#{db['password']} -h #{db['host']} #{db['database']}"
    else
      exec "mysqlimport -u #{db['username']} -p#{db['password']} #{db['database']} #{file}"
    end
  end
end

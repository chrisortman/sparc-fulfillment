namespace :sparc do
  task :bootstrap => ["db:create", :environment] do

    if database_exists?
      puts "Running migrations"
      Rake::Task["db:migrate"].invoke
    end
  end

  def database_exists?
    ActiveRecord::Base.connection
  rescue ActiveRecord::NoDatabaseError
    false
  else
    true
  end

  def table_created?(table)
    ActiveRecord::Base.connection.tables.include?(table)
  end
end

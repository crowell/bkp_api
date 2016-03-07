require 'dm-migrations'

desc "migrates the db"
task :migrate do
	require './main'
	DataMapper.auto_migrate!
end

desc "upgrades the db"
task :upgrade do
	require './main'
	DataMapper.auto_upgrade!
end


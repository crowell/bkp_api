require 'json'
require 'sinatra'
require 'data_mapper'
require 'dm-migrations'
require 'securerandom'
require 'rest-client'

configure :development do
	DataMapper::Logger.new($stdout, :debug)
	DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/bkp.db")
end

configure :production do
	DataMapper::Logger.new($stdout, :debug)
	DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/bkp.db")
end

require './models/init'
require './routes/init'
DataMapper.finalize

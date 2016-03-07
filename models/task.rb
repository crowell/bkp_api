class Task
	include DataMapper::Resource
	property :id, Serial
	property :title, String, :required => true, :unique => true
	property :station, String, :required => true, :unique => true
	property :points, Integer, :required => true
	property :flag, String, :required => true, :unique => true
	property :description, Text, :required => true, :unique => true
	property :visible, Boolean, :required => true, :default => false
	property :created_at, DateTime
end

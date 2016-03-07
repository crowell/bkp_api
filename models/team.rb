class Team
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :required => true, :unique => true
	property :email, String, :required => true, :unique => true
	property :apikey, String, :required => true, :unique => true
	property :created_at, DateTime
end

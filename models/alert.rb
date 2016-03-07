class Alert
	include DataMapper::Resource
	property :id, Serial
	property :text, String, :required => true, :unique => true
	property :created_at, DateTime
end

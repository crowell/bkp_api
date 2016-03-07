class Response
	include DataMapper::Resource
	property :id, Serial
	property :chall_id, Integer, :required => true
	property :team_id, Integer, :required=>true
	property :flag, Text, :required => true
	property :created_at, DateTime
end

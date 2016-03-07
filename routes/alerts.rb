require 'date'
get '/api/alerts' do
	a = Alert.all
	status 200
	a.to_json
end


post '/api/alerts' do
	admin = valid_key?(params[:key]) == "admin"
	if admin != true
		status 403
		return
	end
	text = params[:text]
	t = Alert.create(
		:text => text
	)
	if t.saved?
		"alert saved"
		status 201
	else
		status 409
		"this alert already exists"
	end
end

get '/api/last_score' do
	t = Solve.last
	if not t.nil?
		return t.created_at.to_s
	end
	return DateTime.new(2001,2,3).to_s
end

get '/api/last_scoreboard' do
	t = Task.last
	if not t.nil?
		return t.created_at.to_s
	end
	return DateTime.new(2001,2,3).to_s
end

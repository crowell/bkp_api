get '/api/pwnpoints' do
	api = params[:key]
	t = Team.first(:apikey => api)
	q = "select solves.team_id, sum(solves.points) as pwnpoints from tasks inner join solves on solves.chall_id=tasks.id where tasks.description like 'pwn%' group by team_id;"
	resp = DataMapper.repository.adapter.select(q)
	win = "if you register for a round and are clearly wasting our time* you will not be able to register for 3 more rounds \n  you will receive an email with details on how and where to host the exploit\n * this will be decided by the author, but in general it means submissions that clearly aren't attempting to exploit the binary..."
	resp.each{|r|
		if r.team_id == t.id
			if r.pwnpoints.to_i > 20
				return "email your api key to qwn2own@gmail.com  and you will be added to this round :-)\n" + win
			else
				return "you need at least 20 pwnpoints to play\n"
			end
		end
	}
end

get '/api/teams' do
	q = "SELECT teams.name, SUM(solves.points) as c, MAX(solves.created_at) as last_score FROM teams  JOIN solves ON team_id = teams.id GROUP BY teams.id ORDER BY c DESC, last_score ASC;"
	resp = DataMapper.repository.adapter.select(q)
	arr = []
	resp.each{|i|
		h = Hash.new
		h["team"] = i.name
		h["points"] = i.c.to_i
		arr << h
	}
	arr.to_json
end

get '/api/teams/:num' do
	q = "SELECT teams.name, SUM(solves.points) as c, MAX(solves.created_at) as last_score FROM teams  JOIN solves ON team_id = teams.id GROUP BY teams.id ORDER BY c DESC, last_score ASC;"
	resp = DataMapper.repository.adapter.select(q)
	arr = []
	resp.each{|i|
		h = Hash.new
		h["team"] = i.name
		h["points"] = i.c.to_i
		arr << h
	}
	arr = arr.take(params[:num].to_i)
	arr.to_json
end

get '/api/myrank' do
	apikey = URI.unescape params['key']
	myteam = Team.first(:apikey => apikey)
	if myteam.nil?
		status 400
		"not valid"
	end
	s = Solve.all
	h = Hash.new()
	s.each{|solve|
		team_n = Team.first(:id => solve.team_id)
		team_name = team_n.name
		if h.include? team_name
			h[team_name][0] += solve.points
			dt = h[team_name][1]
			if dt < solve.created_at
				h[team_name][1] = solve.created_at
			end
		else
			h[team_name] = [solve.points, solve.created_at]
		end
	}
	jsa = []
	h.sort_by { |k, v| v }.each { |team|
		m = Hash.new()
		m["team"] = team[0]
		m["points"] = team[1][0]
		jsa << m
	}
	jsa.each_with_index{|js,idx|
		if js["team"] == myteam.name
			status 200
			return (idx+1).to_json
		end
	}
end

get '/api/solves' do
	apikey = URI.unescape params['key']
	team = Team.first(:apikey => apikey)
	if not team.nil?
		s = Solve.all(:team_id => team.id)
		s.to_json
	end
end

get '/api/team' do
	apikey = URI.unescape params['key']
	team = Team.first(:apikey => apikey)
	if team.nil?
		status 400
		"not valid"
	end
	status 200
	team.name
end

post '/api/teams' do
	apikey = SecureRandom.hex
	teamname = URI.unescape params['name']
	email = URI.unescape params['email']
	t = Team.create(
		:name => teamname,
		:email => email,
		:apikey => apikey
	)
	if t.saved?
		begin
			resp = RestClient.post "https://api:key-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"\
				"@api.mailgun.net/v3/bostonkey.party/messages",
				:from => "Boston Key Party <do-not-reply@bostonkey.party>",
				:to => "#{email}",
				:subject => "Boston Key Party API Key",
				:text => "Your API Key for team #{teamname} for BKP is\n\n#{apikey}\n\nThis key is used for getting challenges, submit flags, etc. Don't Lose It!\n\n-- The BKP Team"
			if resp.code == 400
				status 409
				t.destroy
				return
			end
		rescue
			status 409
			t.destroy
			return
		end
		status 201
	else
		status 409
		"email or team name is taken"
	end
end

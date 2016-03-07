get '/api/tasks' do
	admin = valid_key?(params[:key]) == "admin"
	key = params[:key]
	team = Team.first(:apikey => key)
	tasks = []
	Task.each{|task|
		jst = JSON.parse(task.to_json)
		s = Solve.all(:chall_id => task.id).count
		if not admin
			jst["flag"] = "NOT AUTHORIZED"
		end
		jst["solved"] = false
		jst["solves"] = s
		if not team.nil?
			chid = task.id
			team_solves = Solve.all(:team_id=>team.id)
			this_task_solves = team_solves.all(:chall_id=>chid).count
			if this_task_solves != 0
				jst["solved"] = true
			end
		end
		if jst["visible"]
			tasks << jst
		end
	}
	tasks.to_json
end

get '/api/tasks/:id' do
	admin = valid_key?(params[:key]) == "admin"
	t = Task.get(params[:id])
	if not t.visible?
		halt 404
	end
	if t.nil?
		halt 404
	end
	if not admin
		t["flag"] = "NOT AUTHORIZED"
	end
	s = Solve.all(:chall_id => params[:id]).count
	j = JSON.parse(t.to_json)
	j["solves"] = s
	j.to_json
end

post '/api/tasks' do
	admin = valid_key?(params[:key]) == "admin"
	if not admin
		halt 401
	end
	body = JSON.parse(request.body.read)[0]
	t = Task.create(
		:title => body['title'],
		:station => body['station'],
		:points => body['points'].to_i,
		:flag => body['flag'],
		:description => body['description'],
		:visible => false
	)
	status 201
	t.to_json
end

post '/api/response' do
	key = params[:key]
	team = Team.first(:apikey => key)
	if team.nil?
		status 401
		return
	end
	chall = Task.get(params[:id])
	if chall.nil?
		status 400
		return
	end
	ckey = chall.flag
	flg = URI.unescape(params['flag'])
	puts flg
	puts ckey
	gotit = (ckey == flg)
	resp = Hash.new
	response = Response.create(
		:chall_id => params[:id],
		:team_id => team.id,
		:flag => flg
	)
	resps = Solve.all(:team_id => team.id)
	if resps.count != 0
		solved = resps.all(:chall_id => response.chall_id).count != 0
		if solved
			resp["reply"] = "you already solved this"
			status 406
			return
		end
	end
	if gotit
		s = Solve.create(
			:chall_id => response.chall_id,
			:team_id => team.id,
			:points => chall.points
		)
		resp["reply"] = "you did it!"
		status 200
	else
		resp["reply"] = "wrong flag"
		status 406
	end
end

put '/api/tasks/:id' do
	admin = valid_key?(params[:key]) == "admin"
	if not admin
		halt 401
	end
	body = JSON.parse request.body.read
	t = Task.get(params[:id])
	if t.nil?
		halt 404
	end
	halt 500 unless Task.update(
		title: body['title'],
		points: body['points'].to_i,
		flag: body['flag'],
		station: body['station'],
		description: body['description']
	)
	t.to_json
end

delete '/api/tasks/:id' do
	admin = valid_key?(params[:key]) == "admin"
	if not admin
		halt 401
	end
	t = Task.get(params[:id])
	if t.nil?
		halt 404
	end
	halt 500 unless t.destroy
end

get '/api/solves' do
	s = Solve.all
	s.to_json
end

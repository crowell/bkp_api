helpers do
	def valid_key? (key)
		# returns "admin" if admin
		if key == "cool_admin_key_you_cant_guess"
			return "admin"
		else
			return "noob"
		end
	end
end
require_relative './tasks.rb'
require_relative './teams.rb'
require_relative './alerts.rb'

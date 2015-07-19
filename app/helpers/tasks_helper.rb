module TasksHelper

	def loader_url
		'http://wpc.077d.edgecastcdn.net/00077D/fender/images/2013/template/drop-nav-loader.gif'
	end

	def due_string(due)
		if due
			due = due+ Time.zone_offset("PDT")
			return due.strftime("%l:%M %p %a %m/%d/%y")
		end
		return ''
	end

end
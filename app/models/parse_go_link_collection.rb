class ParseGoLinkCollection < ParseResource::Base

	fields :data, :member_emails, :permissions, :name


	def self.example_data
		data = "name: Example Collection Configuration
description: This is an example collection. You can copy and paste this to start your collection.
links: 
- Group 1:
  - pbl.link/link1
  - pbl.link/link2
  - pbl.link/link3
- Group 2:
  - pbl.link/link3
  - pbl.link/link4
  - pbl.link/link5
- Group 3:
  - pbl.link/link7"
  		return data
	end
end
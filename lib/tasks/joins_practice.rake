namespace :joins do
	task :member_committee  => :environment do
		sql_query = "SELECT 
			m.name as name, 
			m.email as email,
			c.name as committee,
			c.id as committee_id,
			m.id as member_id
			FROM members as m
			JOIN committee_members as cm ON m.id = cm.member_id
			JOIN committees as c ON cm.committee_id = c.id
			WHERE cm.semester_id = " + Semester.current_semester.id.to_s+" ORDER BY c.name"


		j = ActiveRecord::Base.connection.execute(sql_query)

		j.each do |join_item|
			join_item['custom_field'] = 'hello'
			puts join_item
		end

	end
end 
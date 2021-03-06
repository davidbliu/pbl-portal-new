task :remove_commitments => :environment do
  Commitment.destroy_all
end




  



task :test_commitments => :environment do
  Member.all.each do |member|
    p 'hi'
  end
end

task :apprentice_scores => :environment do

  current_cms = Member.current_members

    
  CSV.open("attendance.csv", "w") do |csv|
    for cm in current_cms
      attended_event_members = EventMember.where("event_id IN (?)", Event.this_semester.pluck(:id).collect{|i| i.to_s})
      attended_event_ids = attended_event_members.where(member_id: cm.id).pluck(:event_id)
      attended_events = Event.where("id in (?)", attended_event_ids.collect{|i| i.to_s})
      for event in attended_events
        csv << [event.name, cm.name]
      end
    end
  end
end
task :export_member_data => :environment do

  current_members = Member.current_members

    
  CSV.open("exported_member_data.csv", "w") do |csv|
    for cm in current_members
      csv << [cm.name, cm.current_committee.name]
    end
  end
end
task :export_recent_events => :environment do

   CSV.open("exported_recent_events.csv", "w") do |csv|
    csv << ["Event", "Time"]
    for event in Event.this_semester
      csv << [event.name, event.start_time]
    end
  end
end
task :export_attendance => :environment do 
  CSV.open("attendance.csv", "w") do |csv|
    for event in Event.this_semester
      csv << [event.name, event.start_time]
    end
  end
end



task :clear_scavenger => :environment do 
  p 'destroying all previous scavenger data'
  ScavengerPhoto.destroy_all
  ScavengerTheme.destroy_all
  ScavengerGroup.destroy_all
  ScavengerGroupMember.destroy_all
end


task :sweet_tooth => :environment do 
  theme = ScavengerTheme.new
  theme.name = 'Altitude'
  theme.start_time = DateTime.now
  theme.end_time = DateTime.now + 1.week
  theme.description = '...'
  theme.save!
end
task :scavenger_setup => :environment do
  p 'destroying all previous scavenger data'
  ScavengerPhoto.destroy_all
  ScavengerTheme.destroy_all
  ScavengerGroup.destroy_all
  ScavengerGroupMember.destroy_all


  # create themes
  p 'creating new scavenger themes'
  themes = ['Rocks', 'Fruits', 'Vegetables', 'Candies', 'Monsters', 'Gollumns', 'Pickles']
  wks = -2
  themes.each do |t|
    theme = ScavengerTheme.new
    theme.name = t
    theme.start_time = DateTime.now + wks.week
    theme.end_time = DateTime.now + wks.week+1.week
    wks = wks + 1
    theme.description = 'there is no description for dis fake ass theme'
    theme.save!
  end

  # generate groups for each theme
  p 'generating groups for all themes'
  ScavengerTheme.all.each do |t|
    p 'generating groups for '+t.name
    t.generate_groups
  end

  # upload some photos

  uploaded = 0
  group_ids = ScavengerGroup.all.pluck(:id)
  photos = []
  photos = ['https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xpa1/v/t1.0-9/10407208_888820504501962_7467913295809253414_n.jpg?oh=b0621ab50fee202849e142719898fe9a&oe=559061F7&__gda__=1434673231_2e4ed73794f7de5396ff88156cda4e51', 'https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xfa1/v/t1.0-9/10968421_10155176148625224_1724730368016353616_n.jpg?oh=531440bd0456ef07d58a99f52aa912bc&oe=55496198&__gda__=1430834293_95e2049f2fe3e8d4aaaf3f899dbdf660', 'https://scontent.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/10994267_10205917382802867_445098120182874756_n.jpg?oh=92ec66789ecdb7cdc70bba1cfe2f12b6&oe=55541BC0', 'https://fbcdn-sphotos-e-a.akamaihd.net/hphotos-ak-xfa1/v/t1.0-9/10408612_10203873276056821_8609842597603869620_n.jpg?oh=0ba1b212e35e3ec6063573ec17ee9003&oe=557C9CCE&__gda__=1431148835_8817d8239fc8ca297ed3a2ead7d0128d', 'https://scontent.xx.fbcdn.net/hphotos-xfp1/v/t1.0-9/11012889_10155248591230254_5008750923109993004_n.jpg?oh=f02d504e2fce3f293ba3e237367ab1f0&oe=557FE44D', 'https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/10562985_10153088972158606_2477958870754629164_n.jpg?oh=9cf17cbb7b3ddd3f7dfe6d30de48b9c6&oe=554A6AEE&__gda__=1435374219_5e1b12445e9ec5f96eb4ba4c6556b3a2', 'https://scontent.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/10665903_10204897172336179_1036979249881467817_n.jpg?oh=b9f4074423cee70d298f58279461ff1d&oe=559233AD', 'https://scontent.xx.fbcdn.net/hphotos-xaf1/v/t1.0-9/10881593_10152456985666566_1591312908983757685_n.jpg?oh=4f6797cd518ca7bef16343919f6839f0&oe=559467FE', 'https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/1000275_10152313666611566_1397493957982345114_n.jpg?oh=88b8184eaa731e1afa523bd40605cd43&oe=559204E8&__gda__=1434237655_9a5aeab12ed41ac56632c55d9f81f265', 'https://scontent.xx.fbcdn.net/hphotos-xpa1/v/t1.0-9/10945041_10152635587522844_7021494383217248241_n.jpg?oh=1a36902f87e9f362bb822ff33fa47d58&oe=557DE778', 'https://fbcdn-sphotos-f-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/10991228_950964071581860_3005179335830669183_n.jpg?oh=d074c3525fac3257c1b5a42bc017b37f&oe=558470FB&__gda__=1434833809_8326c162680252ce0175d1c7dce5e495', 'https://fbcdn-sphotos-b-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/p206x206/10990430_860139610717181_5322428113938953098_n.jpg?oh=a3730505bdaf6c03a9a3b660e8acdb15&oe=558FFF89&__gda__=1434549812_338d9823d29227ec4321d336bb9979c8', 'https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/11001871_860140264050449_8248910529853114821_n.jpg?oh=1dd8eb33847702249522169c5b0b88fd&oe=5551F500&__gda__=1435343753_1ca6b521ff222ca938b9ffca0fc0ca41', 'https://fbcdn-sphotos-d-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/10993396_860140937383715_7226196540839975825_n.jpg?oh=518f5270e13db5e593b2904ede08ce2b&oe=5588AB7B&__gda__=1430821905_a2d62f10e9e05561fcc5b9f9332b4908', 'https://scontent.xx.fbcdn.net/hphotos-xfp1/v/t1.0-9/11001939_860141304050345_4146723772486479956_n.jpg?oh=cf52191b5bc93c18a1e8266649c3e4ba&oe=5551C35A', 'https://scontent.xx.fbcdn.net/hphotos-xpa1/v/t1.0-9/10167947_860141730716969_7966127562865781517_n.jpg?oh=fce582603ec41a7ac93b18967224c14f&oe=5580C4D7', 'https://scontent.xx.fbcdn.net/hphotos-xpa1/v/t1.0-9/10423908_860142800716862_5379507402426536720_n.jpg?oh=68f25cffb3e53fda47dc4b9ddab29866&oe=5583C139', 'https://fbcdn-sphotos-b-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/1517486_860144067383402_1360290727376121830_n.jpg?oh=ca377273e4061b2864011be1096e9496&oe=557F932B&__gda__=1435582384_3e4aa37cd26144dfb23741d0562111a0', 'https://fbcdn-sphotos-b-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/10978671_860144337383375_3289823746475307697_n.jpg?oh=7ef6466c5debeb7d3dfc46ddf3b104f3&oe=55936AB0&__gda__=1435338970_897b82138a0421ee39906cc4799f37a0', 'https://scontent.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/10609507_10203558613953853_1368931319124436855_n.jpg?oh=2f2e84169465faf1f7009af2a1430000&oe=557F74']

  p 'about to upload '+photos.length.to_s+' photos to scavenger'
  photos.each do |p|
    # upload it for some group that has not already uploaded a photo
    group = ScavengerGroup.find(group_ids.sample)
    while ScavengerPhoto.where(group_id: group.id).length > 0
      group = ScavengerGroup.find(group_ids.sample)
      p 'already uploaded, finding a new group'
    end
    photo = ScavengerPhoto.new
    photo.group_id = group.id
    photo.image = p
    photo.points = 10
    photo.save!
    p uploaded.to_s+' photo successfully uploaded'
    uploaded = uploaded+1
  end
  


end


task :maptest => :environment do
	p 'hi'
  events = Event.all
	current_member = Member.where(name: "David Liu").first
  p current_member.attendance_id_mapping(events)
end

task :rankings => :environment do
	current_member = Member.where(name: "David Liu").first
	# semester_events
	attended_event_members = EventMember.where("event_id IN (?)", Event.this_semester.pluck(:id).collect{|i| i.to_s})
	attended_event_ids = attended_event_members.where(member_id: current_member.id).pluck(:event_id)
	@attended_events = Event.where("id in (?)", attended_event_ids.collect{|i| i.to_s})

	@attended_events.all.each do |event| 
		p event.name + ": " + event.points.to_s + " points"
	end

	p 'calculating cm points'
	cm_points_list = current_member.cms.map{|cm| {'name' => cm.name, 'points' => cm.total_points}}
	@cm_points_list = cm_points_list.sort_by{|obj| obj['points']}.reverse
	p @cm_points_list

	p 'calculating all member points'
	points_list = Member.all.map{|m| {'name' => m.name, 'points' => m.total_points}}
	@points_list = points_list.sort_by{|obj| obj['points']}.reverse
	p @points_list
end

task :mark => :environment do
	# p Member.current_gm_ids
	@semester_events = Event.this_semester
		@current_cms = Member.current_members
		# event_member_join = Event.join(curr)
		event_members = EventMember.all
		# @attended_dict = 
		@current_cms.each do |cm|

			# @semester_events.each do |event|
			# 	if event_members.where(event_id: event.id.to_s).where(member_id: cm.id).length > 0
			# 		p 'yes'
			# 	else
			# 		p 'no'
			# 	end
			# end

			#
			# generate record of cm events
			#
			
			begin
				mapping = cm.attendance_mapping(@semester_events)
				p cm.name
				p mapping
				# p attended
			rescue
				name = cm.name
				p 'failed here'
				# p cm.name
				# current_member = Member.where(name: name).first
				# mems = EventMember.where(member_id: current_member.id)
				# for m in mems
				# 	if m.event_id.length > 5 or m.event_id == ""
				# 		p m.event_id
				# 		m.destroy
				# 	end
				# end

			end
		end
end



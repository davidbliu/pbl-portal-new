



task :points_test => :environment do
	p 'hi'
	Member.all.each do |mem|
		p mem.total_points
	end
	p 'bye'
end
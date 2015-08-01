class ParseGoLinkBundle < ParseResource::Base
  fields :name, :keys, :member_emails

  def self.import
  	ParseGoLinkBundle.create(name:'PBL Links Team Resources', keys:['pbl-links-fb', 'pbl-links-cca', 'daily-scrum', 'links-trello'], member_emails:['davidbliu@gmail.com'])
  end

  # def self.migrate_urls
  # 	ParseGoLinkBundle.all.each do |bundle|
  # 		ParseGoLink.(limit)
  # 		bundle.keys.each d
  # end

  def self.get_bundles(email)
  	ParseGoLinkBundle.all.to_a
  end
end
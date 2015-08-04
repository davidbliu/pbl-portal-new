class ParseGoLinkBundle < ParseResource::Base
  fields :name, :keys, :member_emails, :groups

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

  """ caching logic for permissions"""

  def self.my_bundles(email)
    options = { :namespace => "app_v1", :compress => true }
    dalli_client = Dalli::Client.new(ENV['MEMCACHED_HOST'], options)

    permissions_hash = dalli_client.get('bundles_permissions_hash')
    valid_emails = Set.new(permissions_hash.keys)
    if permissions_hash.keys.include?(email)
      permitted_bundle_ids = permissions_hash[email]
      return ParseGoLinkBundle.limit(1000000).all.to_a.select{|x| permitted_bundle_ids.include?(x.id)}
    end
    return Array.new
  end

  
  def self.cache_permissions
    bundles = ParseGoLinkBundle.limit(10000000).all.to_a
    # puts 'getting bundles'
    group_bundles = Hash.new
    groups = Array.new
    group_bundles['all'] = Array.new
    bundles.each do |bundle|
      if not bundle.groups or bundle.groups.length == 0
        group_bundles['all'] << bundle.id
      else
        bundle.groups.each do |group|
          if not groups.include?(group)
            group_bundles[group] = Array.new
            groups << group
          end
          group_bundles[group] << bundle.id
        end
      end
    end
    group_bundles.keys.each do |key|
      group_bundles[key] = Set.new(group_bundles[key])
    end
    # puts 'pulling groups'
    groups = ParseGroup.limit(100000).all.to_a
    # puts 'pulled groups'
    # puts 'getting permissions hash'
    """ the permissions hash is a hash from member emails to a set of ids that the member can access """
    permissions_hash = Hash.new
    all_set = group_bundles['all']
    included_emails = Array.new
    groups.each do |group|
      group_bundle_ids = group_bundles[group.name].to_a
      group.member_emails.each do |email|
        if not included_emails.include?(email)
          included_emails << email
          permissions_hash[email] = all_set.to_a
        end
        permissions_hash[email].concat(group_bundle_ids)
      end
    end
    permissions_hash.keys.each do |key|
      permissions_hash[key] = Set.new(permissions_hash[key])
    end

    options = { :namespace => "app_v1", :compress => true }
    dalli_client = Dalli::Client.new(ENV['MEMCACHED_HOST'], options)
    dalli_client.set('bundles_permissions_hash', permissions_hash)
    # puts 'you have permission to view: '+permissions_hash['davidbliu@gmail.com'].to_a.join(',')
    return true
  end
end
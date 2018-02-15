require 'csv'

desc "Get Host Awards"
task :awards => :environment do
  connection = ActiveRecord::Base.connection
  @hosts = connection.execute("select business_name, sum(i.rsvp) as total_rsvps from socialite_development.hosts as h
inner join socialite_development.events as e on h.id = e.host_id
inner join socialite_development.invites as i on i.event_id = e.id
order by total_rsvps
limit 5")
  CSV.open("results.csv","w") do |csv|
    @hosts.each do |host|
      csv << [host[0], host[1]]
    end
  end
end
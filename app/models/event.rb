class Event < ApplicationRecord

  belongs_to :host
  has_many :invites
  has_many :users, through: :invites
  enum event_type: [:public, :invite], _prefix: true

  validates :event_name, :capacity, :event_start, :event_end, :rsvp_start, :rsvp_end, :event_type, :venue_addr1, :venue_city, :venue_state, :venue_zip, presence: true

  def self.get_upcoming_public_events
    self.where(event_type: :public).where('`event_start` >= ?', Time.now)
  end

  def self.get_past_public_events
    self.where(event_type: :public).where('`event_start` < ?', Time.now)
  end

  def self.get_events_for_user(user_id)
    self.find_by_sql(["SELECT e.* FROM socialite_development.events AS e
        LEFT OUTER JOIN socialite_development.invites AS i
        ON i.event_id = e.id
        LEFT OUTER JOIN socialite_development.users as u
        ON u.id = i.user_id
        WHERE (i.user_id = ? OR e.event_type = ?)
        AND e.event_start >= NOW()", user_id, :public])
  end

  def self.get_agenda_for_user(user_id)
    self.find_by_sql(["SELECT e.* FROM socialite_development.events AS e
        LEFT OUTER JOIN socialite_development.invites AS i
        ON i.event_id = e.id
        LEFT OUTER JOIN socialite_development.users as u
        ON u.id = i.user_id
        WHERE (i.user_id = ?)
        AND e.event_start >= NOW()", user_id])
  end

  def self.get_upcoming_events_by_host(host_id)
    self.where(host_id: host_id).where('`event_start` >= ?', Time.now)
  end

  def self.get_past_events_by_host(host_id)
    self.where(host_id: host_id).where('`event_start` < ?', Time.now)
  end

end
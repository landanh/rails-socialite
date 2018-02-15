class User < ApplicationRecord

  attr_accessor :registration_password, :registration_password_repeat
  has_many :invites
  has_many :events, through: :invites
  validates :email_addr, :passwd, :first_name, :last_name, :phone, presence: true
  validates :email_addr, uniqueness: true

  def evaluate_registration
    if registration_password != registration_password_repeat
      errors.add(:registration_password, "and confirmation password don't match")
    elsif registration_password.blank?
      errors.add(:registration_password, 'required')
    end
    
    self.passwd = Digest::SHA256.hexdigest registration_password
  end

  def self.search(search)
    where('first_name LIKE ? OR last_name LIKE ? OR email_addr LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
  end

  def self.get_guest_list(event_id)
    User.select('invites.rsvp as rsvp, users.first_name, users.last_name, users.email_addr, users.phone, invites.additional_guests as additional_guests')
        .joins(:invites).where(invites: { event_id: event_id }).order('invites.rsvp DESC')
  end

  def self.to_csv
    attributes = %w{rsvp first_name last_name email_addr phone additional_guests}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << [
            user.rsvp,
            user.first_name,
            user.last_name,
            user.email_addr,
            user.phone,
            user.additional_guests
        ]
      end
    end
  end
end
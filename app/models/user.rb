class User < ActiveRecord::Base
	has_secure_password
	has_many :friendships
	has_many :friends, through: :friendships, source: :friend
	has_many :friendees, foreign_key: :friend_id, class_name: 'Friendship'
	has_many :friended_by, through: :friendees, source: :user
	has_many :invites
	has_many :friends_invited, through: :invites, source: :friend
	has_many :invitees, foreign_key: :friend_id, class_name: 'Invite'
	has_many :invited_by, through: :invitees, source: :user
	EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
	PASSWORD_REGEX = /(?=.*[a-zA-Z])(?=.*[0-9]).{8,}/
	validates :name, presence:true, length: { in: 2..30 }
	validates :description, presence:true, length: { in: 5..500 }
	validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEX }
	validates :password, presence:true,  length: {in: 8..32}, format: { with: PASSWORD_REGEX }
	before_save do
		self.email.downcase!
	end
end

# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :name, presence: true
  validates :email, format: { with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i }

  has_many :refresh_tokens, dependent: :delete_all
  has_many :blacklisted_tokens, dependent: :delete_all
  has_many :accounts, dependent: :delete_all
  has_many :categories, dependent: :delete_all
  has_many :transactions, dependent: :delete_all
  has_many :user_groups, dependent: :delete_all
  has_many :groups, through: :user_groups

  def self.from_omniauth(auth)
    data = auth.info
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = data.email
      user.password = Devise.friendly_token[0, 20]
      user.name = data.name
      user.avatar_url = data.image
    end
  end
end

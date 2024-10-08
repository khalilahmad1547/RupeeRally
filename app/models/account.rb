# frozen_string_literal: true

class Account < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user }

  belongs_to :user
  has_many :user_transactions, dependent: :nullify
end

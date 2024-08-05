# frozen_string_literal: true

class Transaction < ApplicationRecord
  enum divided_by: { by_none: 0, equally: 1, percent: 2, shares: 3, unequally: 4 }

  validates :description, presence: true
  validates :amount_cents, numericality: { only_integer: true }

  belongs_to :user
  has_many :user_transactions, dependent: :delete_all, inverse_of: 'parent_transaction'
end

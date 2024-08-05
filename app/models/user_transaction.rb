# frozen_string_literal: true

class UserTransaction < ApplicationRecord
  enum transaction_type: { income: 0, expense: 1 }
  enum status: { pending: 0, settled: 1 }

  validates :description, presence: true
  validates :user_share, presence: true
  validates :amount_cents, presence: true

  belongs_to :user
  belongs_to :account
  belongs_to :category
  belongs_to :transaction
end

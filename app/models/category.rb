# frozen_string_literal: true

class Category < ApplicationRecord
  enum :category_type, { income: 0, expense: 1 }

  validates :name, presence: true
  validates :name, uniqueness: { scope: %i[user category_type] }

  belongs_to :user
  has_many :transactions, dependent: :nullify

  def update_balance(balance)
    self.amount_cents += balance
  end
end

# frozen_string_literal: true

class Account < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user }

  belongs_to :user
  has_many :transactions, dependent: :nullify

  def record_expense(amount_cents)
    self.balance_cents -= amount_cents
    self.total_expense_cents += amount_cents
  end

  def record_income(amount_cents)
    self.balance_cents += amount_cents
    self.total_income_cents += amount_cents
  end
end

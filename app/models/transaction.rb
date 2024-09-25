# frozen_string_literal: true

class Transaction < ApplicationRecord
  enum :transaction_type, { individual: 0, transfer: 1, shared: 2 }
  enum :divided_by, { by_none: 0, equally: 1, percent: 2, shares: 3, unequally: 4 }
  enum :direction, { income: 0, expense: 1 }
  enum :status, { pending: 0, settled: 1 }

  validates :description, presence: true
  validates :amount_cents, numericality: { only_integer: true }
  validates :user_share, presence: true

  belongs_to :user
  has_many :child_transactions,
           class_name: 'Transaction',
           foreign_key: 'parent_transaction_id',
           inverse_of: :parent_transaction,
           dependent: :destroy
  belongs_to :parent_transaction,
             class_name: 'Transaction',
             optional: true,
             inverse_of: :child_transactions
  belongs_to :paid_by, class_name: 'User'
  belongs_to :account, optional: true
  belongs_to :category, optional: true
end

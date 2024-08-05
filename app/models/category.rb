# frozen_string_literal: true

class Category < ApplicationRecord
  enum category_type: { income: 0, expense: 1 }

  validates :name, presence: true

  belongs_to :user
  has_many :user_transactions, dependent: :nullify
end
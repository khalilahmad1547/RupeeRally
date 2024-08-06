# frozen_string_literal: true

class Group < ApplicationRecord
  validates :name, uniqueness: { scope: :created_by }

  has_many :user_groups, dependent: :delete_all
  has_many :users, through: :user_groups
  belongs_to :created_by, class_name: 'User'
end

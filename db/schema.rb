# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 20_240_913_113_208) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'accounts', force: :cascade do |t|
    t.string 'name', default: '', null: false
    t.integer 'balance_cents', default: 0, null: false
    t.integer 'total_income_cents', default: 0, null: false
    t.integer 'total_expense_cents', default: 0, null: false
    t.integer 'initial_balance_cents', default: 0, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'user_id'
    t.index %w[user_id name], name: 'index_accounts_on_user_id_and_name', unique: true
    t.index ['user_id'], name: 'index_accounts_on_user_id'
  end

  create_table 'blacklisted_tokens', force: :cascade do |t|
    t.string 'jti'
    t.bigint 'user_id', null: false
    t.datetime 'exp', default: -> { 'CURRENT_TIMESTAMP' }, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['jti'], name: 'index_blacklisted_tokens_on_jti', unique: true
    t.index ['user_id'], name: 'index_blacklisted_tokens_on_user_id'
  end

  create_table 'categories', force: :cascade do |t|
    t.string 'name', default: '', null: false
    t.integer 'amount_cents', default: 0, null: false
    t.integer 'category_type', default: 0, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'user_id'
    t.index %w[user_id name category_type], name: 'index_categories_on_user_id_and_name_and_category_type',
                                            unique: true
    t.index ['user_id'], name: 'index_categories_on_user_id'
  end

  create_table 'groups', force: :cascade do |t|
    t.string 'name', default: '', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'created_by_id'
    t.index %w[name created_by_id], name: 'index_groups_on_name_and_created_by_id', unique: true
  end

  create_table 'refresh_tokens', force: :cascade do |t|
    t.string 'crypted_token'
    t.bigint 'user_id', null: false
    t.datetime 'exp', default: -> { 'CURRENT_TIMESTAMP' }, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['crypted_token'], name: 'index_refresh_tokens_on_crypted_token', unique: true
    t.index ['user_id'], name: 'index_refresh_tokens_on_user_id'
  end

  create_table 'transactions', force: :cascade do |t|
    t.text 'description', default: '', null: false
    t.integer 'amount_cents', default: 0, null: false
    t.integer 'divided_by', default: 0, null: false
    t.string 'selected_date', default: '', null: false
    t.string 'selected_time', default: '', null: false
    t.integer 'transaction_type', default: 0, null: false
    t.integer 'direction', default: 0, null: false
    t.integer 'user_share', default: 0, null: false
    t.integer 'status', default: 0, null: false
    t.integer 'parent_transaction_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'user_id'
    t.bigint 'account_id'
    t.bigint 'category_id'
    t.bigint 'paid_by_id'
    t.index ['account_id'], name: 'index_transactions_on_account_id', where: '(account_id IS NOT NULL)'
    t.index ['category_id'], name: 'index_transactions_on_category_id', where: '(category_id IS NOT NULL)'
    t.index ['paid_by_id'], name: 'index_transactions_on_paid_by_id'
    t.index ['parent_transaction_id'], name: 'index_transactions_on_parent_transaction_id',
                                       where: '(parent_transaction_id IS NOT NULL)'
    t.index ['user_id'], name: 'index_transactions_on_user_id'
  end

  create_table 'user_groups', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'group_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['group_id'], name: 'index_user_groups_on_group_id'
    t.index ['user_id'], name: 'index_user_groups_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'name', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'uid'
    t.string 'avatar_url'
    t.string 'provider'
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  add_foreign_key 'accounts', 'users'
  add_foreign_key 'blacklisted_tokens', 'users'
  add_foreign_key 'categories', 'users'
  add_foreign_key 'groups', 'users', column: 'created_by_id'
  add_foreign_key 'refresh_tokens', 'users'
  add_foreign_key 'transactions', 'accounts'
  add_foreign_key 'transactions', 'categories'
  add_foreign_key 'transactions', 'users'
  add_foreign_key 'transactions', 'users', column: 'paid_by_id'
  add_foreign_key 'user_groups', 'groups'
  add_foreign_key 'user_groups', 'users'
end

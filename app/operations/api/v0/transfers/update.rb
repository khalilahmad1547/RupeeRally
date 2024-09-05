# frozen_string_literal: true

module Api::V0::Transfers
  class Update
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:id).filled(:integer)
        optional(:from_account_id).maybe(:integer)
        optional(:to_account_id).maybe(:integer)
        optional(:description).maybe(:string)
        optional(:amount_cents).maybe(:integer)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user

      yield require_update?
      yield fetch_parent_transaction
      @from_account = yield validate_from_account_id
      @to_account = yield validate_to_account_id
      transaction = yield update_transfer
      Success(json_serialize(transaction))
    end

    private

    attr_reader :current_user, :parent_transaction, :params, :from_account, :to_account

    def require_update?
      return Success() if params.any? { |key, value| key != :id && value.present? }

      Failure('nothing to update')
    end

    def fetch_parent_transaction
      @parent_transaction = current_user
                            .transactions
                            .includes(:user_transactions)
                            .transfer
                            .where('transactions.id = ? ', params[:id])
                            .first

      return Success(parent_transaction) if parent_transaction

      Failure(:not_found)
    end

    def validate_from_account_id
      return Success(nil) if params[:from_account_id].blank?

      from_acc = current_user.accounts.find_by(id: params[:from_account_id])
      return Success(from_acc) if from_acc

      Failure(:from_account_not_found)
    end

    def validate_to_account_id
      return Success(nil) if params[:to_account_id].blank?

      to_acc = current_user.accounts.find_by(id: params[:to_account_id])
      return Success(to_acc) if to_acc

      Failure(:to_account_not_found)
    end

    def update_transfer
      transaction = Api::V0::Transactions::UpdateTransferTransaction.call(update_params)
      Success(transaction)
    rescue ::CustomError, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::StatementInvalid => e
      Failure(e.message)
    end

    def update_params
      {
        parent_transaction:,
        description: params[:description],
        amount_cents: params[:amount_cents],
        from_account:,
        to_account:
      }
    end

    def json_serialize(records)
      Api::V0::TransactionsSerializer.render_as_hash([records], root: :transactions)
    end
  end
end

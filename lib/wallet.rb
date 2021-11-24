# frozen_string_literal: true

require_relative 'secret_key'
require_relative 'transaction'

class Wallet
  def address
    secret_key.addr
  end

  def balance
    current_transaction.utxo_list.sum { |tx| tx['value'] }
  end

  def transfer(amount:, to:)
    raise 'Failure: insufficient balance' if balance < amount + Transaction::FEE

    current_transaction.broadcast(amount: amount, to: to).tap { reset_current_transaction! }
  end

  private

  def current_transaction
    @current_transaction ||= build_transaction
  end

  def reset_current_transaction!
    @current_transaction = build_transaction
  end

  def build_transaction
    Transaction.new(address: address, secret_key: secret_key)
  end

  def secret_key
    @secret_key ||= SecretKey.instance
  end
end

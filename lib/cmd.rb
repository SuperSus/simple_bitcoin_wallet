# frozen_string_literal: true

require_relative 'wallet'

class Cmd
  COMMANDS = %w[address balance transfer].freeze
  HELP_MSG = <<~MSG
    commands:
      address- Show your current address
      balance - Show balance
      transfer <address> <amount> - transfer amount in satoshi
  MSG

  attr_reader :command, :params

  def initialize(command, params = [])
    @command = command
    @params = params
  end

  def validate!
    return 'Choose command!' if command.nil?
    return 'Wrong command!' unless COMMANDS.include?(command)

    return unless command == 'transfer'
    return 'Specify address' unless params[0]

    'Specify amount' unless params[1]
  end

  def help
    puts HELP_MSG
  end

  def run
    case command
    when 'address'
      puts wallet.address
    when 'balance'
      puts "Balance: #{wallet.balance} satoshi"
    when 'transfer'
      address, amount = params

      tx = wallet.transfer(amount: amount.to_i, to: address)
      puts "Success transaction: #{tx}"
    end
  end

  private

  def wallet
    @wallet ||= Wallet.new
  end
end

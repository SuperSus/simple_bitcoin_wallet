# frozen_string_literal: true

require 'bitcoin'
require 'httparty'

class Transaction
  include Bitcoin::Builder

  BLOCKSTREAM_BASE_URL = 'https://blockstream.info/testnet/api'
  FEE = 10_000

  attr_reader :address, :secret_key

  def initialize(address:, secret_key:)
    @address = address
    @secret_key = secret_key
  end

  def broadcast(amount:, to:)
    tx = build_transaction(to: to, amount: amount)
    HTTParty.post(
      URI("#{BLOCKSTREAM_BASE_URL}/tx"),
      headers: { 'Content-Type' => 'application/json' },
      body: tx.to_payload.bth
    ).parsed_response
  end

  def utxo_list
    @utxo_list ||= begin
      response = HTTParty.get(URI("#{BLOCKSTREAM_BASE_URL}/address/#{address}/utxo"))
      raise 'Failed to load utxo list' unless response.code == 200

      response.parsed_response
    end
  end

  private

  def build_transaction(to:, amount:)
    build_tx do |t|
      utxo_list.each do |utxo|
        t.input do |i|
          i.prev_out raw_tx(utxo['txid'])
          i.prev_out_index utxo['vout']
          i.signature_key secret_key
        end
      end

      t.output do |o|
        o.value amount
        o.script { |s| s.recipient to }
      end

      balance = utxo_list.sum { |utxo| utxo['value'] }
      remainder = balance - (amount + FEE)
      next unless remainder.positive?

      t.output do |o|
        o.value remainder
        o.script { |s| s.recipient(address) }
      end
    end
  end

  def raw_tx(id)
    res = HTTParty.get(URI("#{BLOCKSTREAM_BASE_URL}/tx/#{id}/raw"))
    Bitcoin::P::Tx.new(res.body)
  end
end

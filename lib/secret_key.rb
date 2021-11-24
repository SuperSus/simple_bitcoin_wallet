# frozen_string_literal: true

require 'bitcoin'

class SecretKey
  Bitcoin.network = :testnet
  FILE_PATH = File.expand_path('../secret.key', __dir__)

  class << self
    def create
      return if exists?

      Bitcoin::Key.generate.tap { |key | File.write(FILE_PATH, key.to_base58) }
    end

    def instance
      @instance ||= begin
        return extract_from_file if exists?

        create
      end
    end

    private

    def exists?
      File.exist?(FILE_PATH)
    end

    def extract_from_file
      Bitcoin::Key.from_base58(File.read(FILE_PATH))
    end
  end
end

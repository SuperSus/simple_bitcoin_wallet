# frozen_string_literal: true

require 'bitcoin'

class SecretKey
  Bitcoin.network = :testnet
  FILE_PATH = File.expand_path('../secret.key', __dir__)

  class << self
    def create
      return if exists?

      key = Bitcoin::Key.generate
      File.write(FILE_PATH, key.to_base58)
    end

    def instance
      @instance ||= begin
        return extract_from_file if exists?

        create
        extract_from_file
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

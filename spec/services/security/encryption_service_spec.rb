# frozen_string_literal: true

RSpec.describe Security::EncryptionService do
  describe '.encrypt' do
    it 'encrypts and decrypts the message' do
      expect(described_class.decrypt(described_class.encrypt('bla'))).to eq 'bla'
    end
  end
end

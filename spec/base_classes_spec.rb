# frozen_string_literal: true

RSpec.describe 'Base classes load' do
  it { expect(ApplicationRecord).to be }
  it { expect(ApplicationMailer).to be }
  it { expect(ApplicationJob).to be }
  it { expect(ApplicationCable::Connection).to be }
  it { expect(ApplicationCable::Channel).to be }
end

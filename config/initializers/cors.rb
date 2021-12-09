# frozen_string_literal: true

allow do
  origins 'http://localhost:3000'

  resource '*',
           headers: :any,
           methods: [:get, :post, :put, :patch, :delete, :options, :head]
end

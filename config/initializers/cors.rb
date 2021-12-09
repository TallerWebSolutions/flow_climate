# frozen_string_literal: true

allow do
  origins 'example.com'

  resource '*',
           headers: :any,
           methods: [:get, :post, :put, :patch, :delete, :options, :head]
end

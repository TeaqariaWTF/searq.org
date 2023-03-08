# frozen_string_literal: true

class HelloController < ApplicationController
  def index
    @token = cookies[:token].presence || generate_token
    @url = "#{request.base_url}/api"
    @q = %w[
      ruby
      rails
      javascript
      react
      vue
      angular
      node
      python
      django
      flask
      elixir
    ].sample
    @code = "curl -G -H \"Authorization: Token #{@token}\" #{@url}/search.json -d \"q=#{@q}\""
  end

  private

  def generate_token
    token = Token.create!
    cookies[:token] = { value: token.key, expires: token.expires_at }
    cookies[:token]
  end
end

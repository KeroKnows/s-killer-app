# frozen_string_literal: true

# Represents an HTTP response and provides useful functionalities
class HttpResponse
  def initialize(response, http_error)
    @response = response
    @http_error = http_error
  end

  def parse
    raise(@http_error[@response.code]) unless successful?

    @response.parse
  end

  def successful?
    !@http_error.keys.include?(@response.code)
  end
end

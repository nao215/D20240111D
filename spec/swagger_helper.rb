# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  def url
    ENV['HOST_URL'].present? ? "https://#{ENV['HOST_URL']}" : 'http://localhost:3000'
  end

  def doorkeeper_application
    Doorkeeper::Application.last
  rescue StandardError
    nil
  end

  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: "#{url}",
          variables: {
            defaultHost: {
              default: "#{ENV.fetch('HOST_URL', 'localhost:3000')}"
            },
            client_id: {
              default: "#{doorkeeper_application&.uid}"
            },
            client_secret: {
              default: "#{doorkeeper_application&.secret}"
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            name: 'Authorization',
            type: 'http',
            description: 'JWT Authorization header using the Bearer scheme.',
            scheme: 'bearer',
            bearerFormat: 'JWT'
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end

def serialize(resource, option = {})
  ActiveModelSerializers::SerializableResource.new(
    resource,
    option
  ).serializable_hash.as_json
end

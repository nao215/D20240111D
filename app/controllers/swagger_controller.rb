class SwaggerController < ApplicationController
  def yaml
    render file: Rails.root.join('/swagger/v1/swagger.yaml'), content_type: 'application/x-yaml'
  end
end

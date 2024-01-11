# typed: true
class PagesController < ApplicationController
  def health_check
    head :ok
  end
end

# typed: true
# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  attr_reader :user, :note

  def initialize(user, record)
    @user = user
    @note = record
  end

  def index?
    note.user_id == user.id
  end

  def update?
    user.id == note.user_id
  end

  # Additional policy methods can be added here
end

class Note < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :title, presence: { message: I18n.t('activerecord.errors.messages.blank') }
  validates :content, presence: { message: I18n.t('activerecord.errors.messages.blank') }

  # Callbacks
  before_create :set_timestamps

  private

  def set_timestamps
    self.created_at = Time.current
    self.updated_at = Time.current
  end
end

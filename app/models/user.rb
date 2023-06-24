# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  name            :string           not null
#  password_digest :string           not null
#  phone           :string
#  role            :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  has_secure_password

  enum role: { client: 0, admin: 1, provider: 2 }

  with_options presence: true do
    validates :name, length: { maximum: 50 }
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, length: { minimum: 6 }, if: :password_required?
    validates :role, inclusion: { in: %w[client admin provider] }
  end

  validates :phone, length: { is: 11 }, numericality: { only_integer: true }, allow_nil: true

  private

  def password_required?
    new_record? || password.present?
  end
end

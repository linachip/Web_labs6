# frozen_string_literal: true

require 'active_record'

class User < ActiveRecord::Base
  has_many :todos
  validates :password, presence: true, length: 6..20
  validates :name, presence: true
  validates :email, uniqueness: true, presence: true, format: URI::MailTo::EMAIL_REGEXP
end

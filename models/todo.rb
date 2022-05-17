# frozen_string_literal: true

require 'active_record'

class Todo < ActiveRecord::Base
  belongs_to :user
end

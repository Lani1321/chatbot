class User < ApplicationRecord
  validates_presence_of :phone_number
end

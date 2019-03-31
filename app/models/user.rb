class User < ApplicationRecord
  validates :user_id, uniqueness: true
end

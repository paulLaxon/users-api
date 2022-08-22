class User < ApplicationRecord
  def to_s
    "first: #{first_name}, last: #{last_name}, email: #{email}, gov id: #{gov_id_number}, id type: #{gov_id_type}"
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :user1 do
    first_name 'John'
    last_name 'Doe'
    email 'john.doe@example.com'
    gov_id_number '11111111'
    gov_id_type 'licence'
  end

  factory :user2 do
    first_name 'Jack'
    last_name 'Doe'
    email 'jack.doe@example.com'
    gov_id_number '22222222'
    gov_id_type 'licence'
  end

  factory :user3 do
    first_name 'Mary'
    last_name 'Smith'
    email 'mary.smith@example.com'
    gov_id_number '33333333'
    gov_id_type 'licence'
  end

  factory :random_user, class: User do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.safe_email }
    gov_id_number { Faker::DrivingLicence.usa_driving_licence('Michigan') }
    gov_id_type 'licence'
  end
end

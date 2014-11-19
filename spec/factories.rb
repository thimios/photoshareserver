FactoryGirl.define do

  factory :user do
    username { Faker::Name.name }
    email { Faker::Internet.email }
    password "password"
    encrypted_password { User.new.send(:password_digest, 'password') }
    gender { ["male", "female"].sample }
    birth_date { 20.years.ago }
    confirmed_at { Time.now }
    latitude 52.5
    longitude 12.6
    admin 1
  end

  factory :category do
    initialize_with { Category.find_or_create_by_id(id)}

    trait :fashion do
      id 1
      title "fashion"
      description "fashion category description"
    end

    trait :place do
      id 2
      title "place"
      description "place category description"
    end

    trait :art do
      id 3
      title "art"
      description "art cat descr"
    end
  end

  factory :photo do
    title {Faker::Lorem.words 2}
    association :category, :fashion
    user
    latitude 52.48929608052652
    longitude 13.421714945981385
    show_on_map true
    banned false
  end

  factory :comment do
    association :owner, factory: :user
    association :commentable, factory: :photo
    body { Faker::Lorem.sentence }


  end
end
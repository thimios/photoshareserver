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

  factory :named_location do
    reference Faker::Lorem.characters("CoQBewAAACPvF7X9k8oESf-dqXAYvf1RbJu51SROVwrEjl8RGl2N1iftFWtUCvsOqRXzbLgcfN1DOcld-AwaVMa-aU5ubmA3QYV0RUb7MtAtUML3qNFOM0PuVTvVR2NC9yOumVui8v5tfVkZYzKj0fvLlwlYHr01RkWLMAEc_2M1ww0IhzpcEhCwLxG5ZDZ7akhO2As18G8GGhQta0Ac3s-DZvGVjBxeL_KDzgt0eg".length)
    google_id Faker::Lorem.characters("72537495dd878b6bd2feb0104e263e730e1e63a0".length)
    latitude Faker::Address.latitude
    longitude Faker::Address.longitude
    name Faker::Name.name
    vicinity Faker::Address.city

    trait :hasenheide do
      reference "CoQBewAAACPvF7X9k8oESf-dqXAYvf1RbJu51SROVwrEjl8RGl2N1iftFWtUCvsOqRXzbLgcfN1DOcld-AwaVMa-aU5ubmA3QYV0RUb7MtAtUML3qNFOM0PuVTvVR2NC9yOumVui8v5tfVkZYzKj0fvLlwlYHr01RkWLMAEc_2M1ww0IhzpcEhCwLxG5ZDZ7akhO2As18G8GGhQta0Ac3s-DZvGVjBxeL_KDzgt0eg"
      google_id "72537495dd878b6bd2feb0104e263e730e1e63a0"
      latitude 52.4834
      longitude 13.4114
      name "Hasenheide Volkspark"
      vicinity "Berlin"
    end
  end

  factory :system_photo do
    image_content_type "image/png"
    title Faker::Lorem.words 2
    image_file_name "defaultavatar.png"
    image_file_size 29681

    trait :banned_image do
      title "banned image"
      image_file_name "bannedphoto.png"
      image_file_size "119371"
    end

    trait :default_avatar do
      title "default avatar"
      image_file_name "defaultavatar.png"
      image_file_size 29681
    end
  end

end
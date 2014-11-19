require 'rails_helper'

describe Comment, :type => :model do

  describe '#as_json' do
    it 'includes extra fields' do
      subject = create(:comment)
      json = subject.as_json
      expect(json['body']).to eq(subject.body)
      expect(json["commentable_id"]).to eq(subject.commentable.id)
      expect(json[:owner_username]).to_not be_nil
      expect(json[:owner_thumb_size_url]).to_not be_nil
      expect(json[:created_at_date]).to_not be_nil
    end
  end
end
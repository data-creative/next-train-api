require 'rails_helper'

RSpec.describe Agency, type: :model do
  it { should belong_to(:schedule) }

  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:timezone) }
end

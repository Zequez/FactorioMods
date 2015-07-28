require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  subject(:bookmark){ create :bookmark }

  it { is_expected.to respond_to :user }
  it { expect(bookmark.build_user).to be_kind_of User }
  it { is_expected.to respond_to :mod }
  it { expect(bookmark.build_mod).to be_kind_of Mod }
end

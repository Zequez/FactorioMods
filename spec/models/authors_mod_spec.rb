require 'rails_helper'

RSpec.describe AuthorsMod, type: :model do
  subject(:authors_mod) { build :authors_mod }

  it { is_expected.to respond_to :mod }
  it { expect(authors_mod.build_mod).to be_kind_of Mod }
  it { is_expected.to respond_to :author}
  it { expect(authors_mod.build_author).to be_kind_of User }
  it { is_expected.to respond_to :sort_order }
  it { expect(authors_mod.sort_order).to be_kind_of Integer }
end

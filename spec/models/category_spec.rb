require 'rails_helper'

RSpec.describe Category, :type => :model do
  it { should respond_to :mods }

  describe '#mods' do
    it 'should return the mods associated with the category' do
      category = create :category
      mods = []
      mods << create(:mod, category: category)
      mods << create(:mod, category: category)
      mods << create(:mod, category: category)
      expect(category.mods).to eq mods
    end
  end

  describe '#slug' do
    subject { create :category, name: 'Banana split canaleta cósmica "123" pepep' }
    it { expect(subject.slug).to eq 'banana-split-canaleta-cosmica-123-pepep' }
  end

  describe '#mods_count' do
    subject(:category) { build :category }

    context 'category has no mods' do
      it { expect(subject.mods_count).to eq 0 }
    end

    context 'category has mods' do
      it 'should be the number of mods' do
        create :mod, category: category
        create :mod, category: category
        create :mod, category: category

        subject.reload

        expect(subject.mods_count).to eq 3
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Subforum, type: :model do
  subject(:subforum) { build :subforum }

  it { is_expected.to respond_to :number }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :url }
  it { is_expected.to respond_to :game_version }
  it { is_expected.to respond_to :scrap? }
  it { is_expected.to respond_to :forum_posts }

  describe '#scrap_itself', vcr: { cassette_name: 'subforum_model_scrap_itself', record: :new_episodes }  do
    it 'should actually scrap the subforum to get the title' do
      subforum.url = 'http://www.factorioforums.com/forum/viewforum.php?f=86'
      subforum.name = ''
      subforum.scrap_itself
      expect(subforum.name).to eq 'Helper mods (<=0.11)'
    end
  end

  describe '#url=' do
    it 'should extract the #number from the #url' do
      subforum.number = 0
      subforum.url = 'http://www.factorioforums.com/forum/viewforum.php?f=86'
      expect(subforum.number).to eq 86
    end

    it 'should set #number to nil if no number was found' do
      subforum.number = 0
      subforum.url = 'http://www.factorioforums.com/forum/viewforum.php?rsadhthnenrsa'
      expect(subforum.number).to eq nil
    end

    it 'should not fail miserably with a nil value' do
      subforum.number = 0
      subforum.url = nil
      expect(subforum.number).to eq nil
    end
  end

  describe 'validation' do
    it 'should be invalid without a #number' do
      subforum.number = nil
      expect(subforum).to be_invalid
    end

    it 'should be invalid without an #url' do
      subforum.url = nil
      expect(subforum).to be_invalid
    end
  end

  describe '.for_scraping' do
    it 'should return all the subforums with #scrap=true' do
      subforums = []
      subforums << create(:subforum, scrap: true)
      create(:subforum, scrap: false)
      subforums << create(:subforum, scrap: true)
      subforums << create(:subforum, scrap: true)

      expect(Subforum.for_scraping).to eq subforums
    end
  end
end

require 'rails_helper'

RSpec.describe Mod, :type => :model do
  describe 'attributes' do
    subject(:mod) { build :mod }

    it { should respond_to :name }
    it { should respond_to :author_name }
    it { should respond_to :description }
    it { should respond_to :summary }

    it { should respond_to :github }
    it { should respond_to :github_url } # Alias of #github
    it { should respond_to :license }

    it { should respond_to :first_version_date }
    it { should respond_to :last_version_date }

    # URLs
    it { should respond_to :license_url }
    it { should respond_to :official_url }
    it { should respond_to :forum_post_url }

    # External counters
    it { should respond_to :forum_comments_count }
    it { should respond_to :comments_count }

    # Tracking data
    it { should respond_to :downloads }
    it { should respond_to :downloads_count }
    it { should respond_to :visits }
    it { should respond_to :visits_count }

    # belongs_to
    it { should respond_to :author }
    it { should respond_to :category }

    # has_many
    it { should respond_to :files }
    it { should respond_to :versions }
    it { should respond_to :assets }
    it { should respond_to :tags }
    it { should respond_to :favorites }
    it { should respond_to :favorites_count }

    describe '#author_name' do
      subject { mod.author_name }
      it { should be_kind_of String }

      context 'there is an #author' do
        it 'should be delegated to #author.name' do
          mod.author_name = 'Hello There'
          mod.author_name.should eq 'Hello There'
          mod.author = build :developer, name: 'Bye Macumbo'
          mod.author_name.should eq 'Bye Macumbo'
        end
      end
    end

    describe '#slug' do
      subject { create :mod, name: 'Banana split canaleta cósmica "123" pepep' }
      it { expect(subject.slug).to eq 'banana-split-canaleta-cosmica-123-pepep' }
    end

    describe '#github_path' do
      it 'should return the last part of the #github URL' do
        mod.github = 'http://github.com/zequez/something'
        expect(mod.github_path).to eq 'zequez/something'
      end
    end


    describe '#versions' do
      it 'should be ModVersion type' do
        mod.versions.build
        expect(mod.versions.first).to be_kind_of ModVersion
      end
    end

    describe '#files' do
      it 'should be ModFile type' do
        mod.files.build
        expect(mod.files.first).to be_kind_of ModFile
      end
    end
  end

  describe 'scopes' do
    describe '.in_category' do
      it 'should filter results by category' do
        mod1 = create(:mod)
        mod2 = create(:mod, category: mod1.category)
        mod3 = create(:mod)

        Mod.in_category(mod1.category).all.should eq [mod1, mod2]
      end
    end

    describe '.sort_by_most_recent' do
      context 'there are no mods' do
        it 'should return empty' do
          Mod.sort_by_most_recent.all.should be_empty
        end
      end

      context 'there are some mods' do
        it 'should return them by #updated_at date' do
          mod1 = create(:mod)
          mod2 = create(:mod)
          mod3 = create(:mod)
          mod2.update_attribute :updated_at, Time.now

          Mod.sort_by_most_recent.all.should eq [mod2, mod3, mod1]
        end
      end
    end

    describe '.sort_by_alpha' do
      it 'should sort the results by #name' do
        mods = []
        mods << create(:mod, name: 'Banana')
        mods << create(:mod, name: 'Avocado')
        mods << create(:mod, name: 'Caca')

        expect(Mod.sort_by_alpha).to match [mods[1], mods[0], mods[2]]
      end
    end

    describe '.sort_by_forum_comments' do
      it 'should sort the results by #forum_comments_count' do
        mods = []
        mods << create(:mod, forum_comments_count: 8)
        mods << create(:mod, forum_comments_count: 1)
        mods << create(:mod, forum_comments_count: 3)
        mods << create(:mod, forum_comments_count: 5)
        mods << create(:mod, forum_comments_count: 4)

        expect(Mod.sort_by_forum_comments).to match [mods[0], mods[3], mods[4], mods[2], mods[1]]
      end
    end

    describe '.sort_by_downloads' do
      it 'should sort the results by #forum_comments_count' do
        mods = []
        mods << create(:mod, downloads_count: 2)
        mods << create(:mod, downloads_count: 1)
        mods << create(:mod, downloads_count: 3)
        mods << create(:mod, downloads_count: 5)
        mods << create(:mod, downloads_count: 4)

        expect(Mod.sort_by_downloads).to match [mods[3], mods[4], mods[2], mods[0], mods[1]]
      end
    end
  end
end

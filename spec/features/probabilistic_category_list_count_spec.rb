require 'rails_helper'

# The category list number of mods count is very misleading. As soon as you start filtering,
# it displays wrong figures, since those values are cached for all the mods.
# To fix this, we are going to display a probabilistic amount of mods in each category when the user
# is filtering.
feature 'Display an index of mods in certain order' do
  scenario 'the user visits the index unfiltered' do
    c1 = create :category
    c2 = create :category
    c3 = create :category
    c4 = create :category
    create :category
    create :mod, categories: [c1, c2]
    create :mod, categories: [c2, c3]
    create :mod, categories: [c4]
    visit '/mods'
    # All  C2     C1     C3     C4      C5
    # 2    2      1      1      1       0
    expect(categories_counts).to eq [3.0, 2.0, 1.0, 1.0, 1.0, 0.0]
  end

  scenario 'the user visits the index filtered by game version' do
    c1 = create :category
    c2 = create :category
    c3 = create :category
    c4 = create :category
    create :category
    gv1 = create :game_version
    create :mod, categories: [c1, c2], game_versions: [gv1]
    create :mod, categories: [c2, c3], game_versions: [gv1]
    create :mod, categories: [c4]
    visit "/mods?v=#{gv1.number}"
    # All  C2     C1     C3     C4      C5
    # 2    2/3*2  1/3*2  1/3*2  1/3*2   0/3*2
    expect(categories_counts).to eq [2.0, 1.3, 0.7, 0.7, 0.7, 0.0]
  end

  scenario 'the user visits the index filtered by game version and by category' do
    c1 = create :category
    c2 = create :category
    c3 = create :category
    c4 = create :category, name: 'potato'
    create :category
    gv1 = create :game_version
    create :mod, categories: [c1, c2], game_versions: [gv1]
    create :mod, categories: [c2, c3], game_versions: [gv1]
    create :mod, categories: [c4]
    visit "/category/potato?v=#{gv1.number}"
    # All  C2     C1     C3     C4      C5
    # 2    2/3*2  1/3*2  1/3*2  1/3*2   0/3*2
    expect(categories_counts).to eq [2.0, 1.3, 0.7, 0.7, 0.7, 0.0]
  end

  def categories_counts
    page.all('.category-filter a').map{|n| n.text.match(/\(~?([\d\.]+)\)/)[1].to_f}
  end
end

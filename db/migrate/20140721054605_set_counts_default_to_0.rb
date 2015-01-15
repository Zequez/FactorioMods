class SetCountsDefaultTo0 < ActiveRecord::Migration
  def change
    Category.all.map{|c|c.update(:mods_count => 0) if c.mods_count.nil?}
    ModFile.all.map{|m|m.update(:downloads_count => 0) if m.downloads_count.nil?}
    Mod.all.map{|m|m.update(:favorites_count => 0) if m.favorites_count.nil?}
    Mod.all.map{|m|m.update(:comments_count => 0) if m.comments_count.nil?}
    Mod.all.map{|m|m.update(:downloads_count => 0) if m.downloads_count.nil?}
    Mod.all.map{|m|m.update(:visits_count => 0) if m.visits_count.nil?}
    Tag.all.map{|m|m.update(:mods_count => 0) if m.mods_count.nil?}

    change_column :categories, :mods_count, :integer, default: 0, null: false
    change_column :mod_files, :downloads_count, :integer, default: 0, null: false
    change_column :mods, :favorites_count, :integer, default: 0, null: false
    change_column :mods, :comments_count, :integer, default: 0, null: false
    change_column :mods, :downloads_count, :integer, default: 0, null: false
    change_column :mods, :visits_count, :integer, default: 0, null: false
    change_column :tags, :mods_count, :integer, default: 0, null: false
  end
end

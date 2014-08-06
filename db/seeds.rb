# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


User.create!(email: 'zequez@gmail.com', name: 'Zequez', password: 'qwfpqwfp', password_confirmation: 'qwfpqwfp', is_admin: true)

Category.create! name: 'Uncategorized',     icon_class: 'fa fa-question-circle'
Category.create! name: 'Sound',             icon_class: 'fa fa-headphones'
Category.create! name: 'Terrain',           icon_class: 'fa fa-globe'
Category.create! name: 'Campaigns',         icon_class: 'fa fa-flag'
Category.create! name: 'Gameplay',          icon_class: 'fa fa-gamepad'
Category.create! name: 'GUI',               icon_class: 'fa fa-desktop'
Category.create! name: 'Manufacturing',     icon_class: 'fa fa-cogs'
Category.create! name: 'Weapons',           icon_class: 'fa fa-bomb'
Category.create! name: 'Transport belts',   icon_class: 'fa fa-indent'
Category.create! name: 'Logistics Network', icon_class: 'fa fa-android'
Category.create! name: 'Oil',               icon_class: 'fa fa-flask'
Category.create! name: 'Ores',              icon_class: 'fa fa-cube'
Category.create! name: 'Texture packs',     icon_class: 'fa fa-picture-o'
Category.create! name: 'Containers',        icon_class: 'fa fa-archive'
Category.create! name: 'Vehicles',          icon_class: 'fa fa-automobile'
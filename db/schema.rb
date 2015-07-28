# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150727221452) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "authors_mods", force: true do |t|
    t.integer "mod_id"
    t.integer "author_id"
    t.integer "sort_order", default: 0, null: false
  end

  add_index "authors_mods", ["author_id"], name: "index_authors_mods_on_author_id", using: :btree
  add_index "authors_mods", ["mod_id"], name: "index_authors_mods_on_mod_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.integer  "mods_count",        default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.string   "icon_class"
    t.string   "slug"
  end

  create_table "categories_mods", force: true do |t|
    t.integer "mod_id"
    t.integer "category_id"
  end

  add_index "categories_mods", ["category_id"], name: "index_categories_mods_on_category_id", using: :btree
  add_index "categories_mods", ["mod_id"], name: "index_categories_mods_on_mod_id", using: :btree

  create_table "downloads", force: true do |t|
    t.integer  "mod_file_id"
    t.string   "ip"
    t.datetime "created_at"
  end

  add_index "downloads", ["mod_file_id"], name: "index_downloads_on_mod_file_id", using: :btree

  create_table "favorites", force: true do |t|
    t.integer  "user_id"
    t.integer  "mod_id"
    t.datetime "created_at"
  end

  add_index "favorites", ["mod_id"], name: "index_favorites_on_mod_id", using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

  create_table "forum_posts", force: true do |t|
    t.integer  "comments_count", default: 0,     null: false
    t.integer  "views_count",    default: 0,     null: false
    t.datetime "published_at"
    t.datetime "last_post_at"
    t.string   "url"
    t.string   "title"
    t.string   "author_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "edited_at"
    t.integer  "mod_id"
    t.integer  "post_number"
    t.boolean  "title_changed",  default: true,  null: false
    t.boolean  "not_a_mod",      default: false
    t.integer  "subforum_id"
  end

  add_index "forum_posts", ["mod_id"], name: "index_forum_posts_on_mod_id", using: :btree
  add_index "forum_posts", ["post_number"], name: "index_forum_posts_on_post_number", using: :btree
  add_index "forum_posts", ["subforum_id"], name: "index_forum_posts_on_subforum_id", using: :btree

  create_table "game_versions", force: true do |t|
    t.string   "number"
    t.datetime "released_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order"
    t.boolean  "is_group",    default: false, null: false
    t.integer  "game_id"
  end

  add_index "game_versions", ["game_id"], name: "index_game_versions_on_game_id", using: :btree

  create_table "game_versions_mods", force: true do |t|
    t.integer "game_version_id"
    t.integer "mod_id"
  end

  add_index "game_versions_mods", ["game_version_id"], name: "index_game_versions_mods_on_game_version_id", using: :btree
  add_index "game_versions_mods", ["mod_id"], name: "index_game_versions_mods_on_mod_id", using: :btree

  create_table "games", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mod_assets", force: true do |t|
    t.integer  "mod_id"
    t.integer  "mod_version_id"
    t.string   "video_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "sort_order",         default: 0, null: false
  end

  add_index "mod_assets", ["mod_id"], name: "index_mod_assets_on_mod_id", using: :btree
  add_index "mod_assets", ["mod_version_id"], name: "index_mod_assets_on_mod_version_id", using: :btree

  create_table "mod_files", force: true do |t|
    t.string   "name"
    t.integer  "mod_id"
    t.integer  "mod_version_id"
    t.integer  "downloads_count",         default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "sort_order",              default: 0, null: false
    t.string   "download_url"
  end

  add_index "mod_files", ["mod_id"], name: "index_mod_files_on_mod_id", using: :btree
  add_index "mod_files", ["mod_version_id"], name: "index_mod_files_on_mod_version_id", using: :btree

  create_table "mod_game_versions", force: true do |t|
    t.integer "game_version_id"
    t.integer "mod_version_id"
    t.integer "mod_id"
  end

  add_index "mod_game_versions", ["game_version_id"], name: "index_mod_game_versions_on_game_version_id", using: :btree
  add_index "mod_game_versions", ["mod_id"], name: "index_mod_game_versions_on_mod_id", using: :btree
  add_index "mod_game_versions", ["mod_version_id"], name: "index_mod_game_versions_on_mod_version_id", using: :btree

  create_table "mod_versions", force: true do |t|
    t.integer  "mod_id"
    t.string   "number"
    t.datetime "released_at"
    t.integer  "sort_order",                   default: 0, null: false
    t.string   "game_versions_string"
    t.string   "precise_game_versions_string"
  end

  add_index "mod_versions", ["mod_id"], name: "index_mod_versions_on_mod_id", using: :btree

  create_table "mods", force: true do |t|
    t.string   "name"
    t.integer  "author_id"
    t.string   "author_name"
    t.datetime "first_version_date"
    t.datetime "last_version_date"
    t.string   "github"
    t.integer  "favorites_count",      default: 0,    null: false
    t.integer  "comments_count",       default: 0,    null: false
    t.string   "license"
    t.string   "license_url"
    t.string   "official_url"
    t.string   "forum_post_url"
    t.integer  "forum_comments_count"
    t.integer  "downloads_count",      default: 0,    null: false
    t.integer  "visits_count",         default: 0,    null: false
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "slug"
    t.text     "summary"
    t.string   "game_versions_string"
    t.text     "description_html"
    t.integer  "forum_post_id"
    t.string   "forum_subforum_url",   default: "",   null: false
    t.string   "forum_url",            default: "",   null: false
    t.text     "media_links"
    t.string   "imgur"
    t.integer  "last_version_id"
    t.datetime "last_release_date"
    t.boolean  "visible",              default: true, null: false
    t.string   "contact",              default: "",   null: false
    t.string   "info_json_name",       default: "",   null: false
  end

  add_index "mods", ["author_id"], name: "index_mods_on_author_id", using: :btree
  add_index "mods", ["category_id"], name: "index_mods_on_category_id", using: :btree
  add_index "mods", ["forum_post_id"], name: "index_mods_on_forum_post_id", using: :btree
  add_index "mods", ["info_json_name"], name: "index_mods_on_info_json_name", using: :btree
  add_index "mods", ["last_version_id"], name: "index_mods_on_last_version_id", using: :btree
  add_index "mods", ["slug"], name: "index_mods_on_slug", unique: true, using: :btree

  create_table "mods_tags", force: true do |t|
    t.integer  "mod_id"
    t.integer  "tag_id"
    t.datetime "created_at"
  end

  add_index "mods_tags", ["mod_id"], name: "index_mods_tags_on_mod_id", using: :btree
  add_index "mods_tags", ["tag_id"], name: "index_mods_tags_on_tag_id", using: :btree

  create_table "search_terms", force: true do |t|
    t.string   "query"
    t.string   "ip"
    t.datetime "created_at"
  end

  create_table "subforums", force: true do |t|
    t.string   "url"
    t.string   "name"
    t.integer  "game_version_id"
    t.boolean  "scrap"
    t.integer  "number"
    t.integer  "forum_posts_count"
    t.datetime "last_scrap_at"
  end

  add_index "subforums", ["game_version_id"], name: "index_subforums_on_game_version_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name"
    t.integer  "mods_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,     null: false
    t.datetime "locked_at"
    t.boolean  "is_dev",                 default: false, null: false
    t.boolean  "is_admin",               default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "slug"
    t.boolean  "autogenerated",          default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

  create_table "visits", force: true do |t|
    t.integer  "mod_id"
    t.string   "ip"
    t.datetime "created_at"
  end

  add_index "visits", ["mod_id"], name: "index_visits_on_mod_id", using: :btree

end

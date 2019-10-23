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

ActiveRecord::Schema.define(version: 20190917165604) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "definitions", force: :cascade do |t|
    t.integer  "word_variant_id"
    t.integer  "number"
    t.text     "definition"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "definitions", ["word_variant_id"], name: "index_definitions_on_word_variant_id", using: :btree

  create_table "editions", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "short_name",         limit: 255
    t.string   "citation",           limit: 255
    t.string   "author",             limit: 255
    t.datetime "date"
    t.string   "work_number_prefix", limit: 255
    t.float    "completeness"
    t.text     "description"
    t.integer  "owner_id"
    t.integer  "work_set_id"
    t.integer  "image_set_id"
    t.integer  "parent_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "public"
  end

  add_index "editions", ["completeness"], name: "index_editions_on_completeness", using: :btree
  add_index "editions", ["image_set_id"], name: "index_editions_on_image_set_id", using: :btree
  add_index "editions", ["owner_id"], name: "index_editions_on_owner_id", using: :btree
  add_index "editions", ["parent_id"], name: "index_editions_on_parent_id", using: :btree
  add_index "editions", ["work_set_id"], name: "index_editions_on_work_set_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.text     "title"
    t.text     "url"
    t.text     "metadata"
    t.text     "credits"
    t.integer  "full_width"
    t.integer  "full_height"
    t.integer  "web_width"
    t.integer  "web_height"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "collection_id"
  end

  add_index "images", ["collection_id"], name: "index_images_on_collection_id", using: :btree

  create_table "line_modifiers", force: :cascade do |t|
    t.integer  "work_id"
    t.integer  "parent_id"
    t.integer  "start_line_number"
    t.integer  "start_address"
    t.integer  "end_line_number"
    t.integer  "end_address"
    t.string   "type",                limit: 255
    t.string   "subtype",             limit: 255
    t.text     "original_characters"
    t.text     "new_characters"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "line_modifiers", ["end_line_number"], name: "index_line_modifiers_on_end_line_number", using: :btree
  add_index "line_modifiers", ["start_line_number"], name: "index_line_modifiers_on_start_line_number", using: :btree
  add_index "line_modifiers", ["work_id"], name: "index_line_modifiers_on_work_id", using: :btree

  create_table "lines", force: :cascade do |t|
    t.integer  "stanza_id"
    t.text     "text"
    t.integer  "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "lines", ["stanza_id"], name: "index_lines_on_stanza_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "notable_id"
    t.string   "notable_type", limit: 255
    t.text     "note"
    t.integer  "owner_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "notes", ["owner_id"], name: "index_notes_on_owner_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "setts", force: :cascade do |t|
    t.text     "name"
    t.text     "metadata"
    t.string   "type",           limit: 255
    t.boolean  "editable"
    t.integer  "nestable_id"
    t.string   "nestable_type",  limit: 255
    t.integer  "owner_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "level_order"
    t.string   "ancestry",       limit: 255
    t.boolean  "is_leaf",                    default: true
    t.integer  "ancestry_depth",             default: 0
  end

  add_index "setts", ["ancestry"], name: "index_setts_on_ancestry", using: :btree
  add_index "setts", ["ancestry_depth"], name: "index_setts_on_ancestry_depth", using: :btree
  add_index "setts", ["is_leaf"], name: "index_setts_on_is_leaf", using: :btree
  add_index "setts", ["nestable_id"], name: "index_setts_on_nestable_id", using: :btree
  add_index "setts", ["nestable_type"], name: "index_setts_on_nestable_type", using: :btree
  add_index "setts", ["owner_id"], name: "index_setts_on_owner_id", using: :btree
  add_index "setts", ["type"], name: "index_setts_on_type", using: :btree

  create_table "stanzas", force: :cascade do |t|
    t.integer  "work_id"
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "stanzas", ["work_id"], name: "index_stanzas_on_work_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "current_edition_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "word_variants", force: :cascade do |t|
    t.integer  "word_id"
    t.string   "endings",        limit: 255
    t.string   "part_of_speech", limit: 255
    t.text     "etymology"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "words", force: :cascade do |t|
    t.string   "word",          limit: 255
    t.string   "sortable_word", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "work_appearances", force: :cascade do |t|
    t.integer  "work_id"
    t.string   "publication", limit: 255
    t.string   "pages",       limit: 255
    t.integer  "year"
    t.datetime "date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "work_appearances", ["work_id"], name: "index_work_appearances_on_work_id", using: :btree

  create_table "works", force: :cascade do |t|
    t.string   "title",            limit: 255
    t.datetime "date"
    t.integer  "number"
    t.string   "variant",          limit: 255
    t.boolean  "secondary_source"
    t.text     "metadata"
    t.integer  "edition_id"
    t.integer  "image_set_id"
    t.integer  "revises_work_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "works", ["edition_id"], name: "index_works_on_edition_id", using: :btree
  add_index "works", ["image_set_id"], name: "index_works_on_image_set_id", using: :btree
  add_index "works", ["revises_work_id"], name: "index_works_on_revises_work_id", using: :btree

end

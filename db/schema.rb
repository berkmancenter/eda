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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130724204511) do

  create_table "definitions", :force => true do |t|
    t.integer  "word_id"
    t.integer  "number"
    t.text     "definition"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "definitions", ["word_id"], :name => "index_definitions_on_word_id"

  create_table "editions", :force => true do |t|
    t.string   "name"
    t.string   "author"
    t.datetime "date"
    t.string   "work_number_prefix"
    t.float    "completeness"
    t.text     "description"
    t.integer  "owner_id"
    t.integer  "work_set_id"
    t.integer  "image_set_id"
    t.integer  "parent_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "editions", ["completeness"], :name => "index_editions_on_completeness"
  add_index "editions", ["image_set_id"], :name => "index_editions_on_image_set_id"
  add_index "editions", ["owner_id"], :name => "index_editions_on_owner_id"
  add_index "editions", ["parent_id"], :name => "index_editions_on_parent_id"
  add_index "editions", ["work_set_id"], :name => "index_editions_on_work_set_id"

  create_table "images", :force => true do |t|
    t.text     "url"
    t.text     "metadata"
    t.text     "credits"
    t.integer  "full_width"
    t.integer  "full_height"
    t.integer  "web_width"
    t.integer  "web_height"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "line_modifiers", :force => true do |t|
    t.integer  "work_id"
    t.integer  "parent_id"
    t.integer  "start_line_number"
    t.integer  "start_address"
    t.integer  "end_line_number"
    t.integer  "end_address"
    t.string   "type"
    t.string   "subtype"
    t.text     "original_characters"
    t.text     "new_characters"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "line_modifiers", ["end_line_number"], :name => "index_line_modifiers_on_end_line_number"
  add_index "line_modifiers", ["start_line_number"], :name => "index_line_modifiers_on_start_line_number"
  add_index "line_modifiers", ["work_id"], :name => "index_line_modifiers_on_work_id"

  create_table "lines", :force => true do |t|
    t.integer  "stanza_id"
    t.text     "text"
    t.integer  "number"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "lines", ["stanza_id"], :name => "index_lines_on_stanza_id"

  create_table "notes", :force => true do |t|
    t.integer  "notable_id"
    t.string   "notable_type"
    t.text     "note"
    t.integer  "owner_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "notes", ["owner_id"], :name => "index_notes_on_owner_id"

  create_table "pages", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "work_set_id"
    t.integer  "image_set_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "pages", ["edition_id"], :name => "index_pages_on_edition_id"
  add_index "pages", ["image_set_id"], :name => "index_pages_on_image_set_id"
  add_index "pages", ["work_set_id"], :name => "index_pages_on_work_set_id"

  create_table "setts", :force => true do |t|
    t.text     "name"
    t.text     "metadata"
    t.string   "type"
    t.boolean  "editable"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
    t.integer  "nestable_id"
    t.string   "nestable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "setts", ["lft"], :name => "index_setts_on_lft"
  add_index "setts", ["nestable_id"], :name => "index_setts_on_nestable_id"
  add_index "setts", ["nestable_type"], :name => "index_setts_on_nestable_type"
  add_index "setts", ["parent_id"], :name => "index_setts_on_parent_id"
  add_index "setts", ["rgt"], :name => "index_setts_on_rgt"
  add_index "setts", ["type"], :name => "index_setts_on_type"

  create_table "stanzas", :force => true do |t|
    t.integer  "work_id"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "stanzas", ["work_id"], :name => "index_stanzas_on_work_id"

  create_table "users", :force => true do |t|
    t.integer  "current_edition_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "words", :force => true do |t|
    t.string   "word"
    t.string   "endings"
    t.string   "part_of_speech"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "work_appearances", :force => true do |t|
    t.integer  "work_id"
    t.string   "publication"
    t.string   "pages"
    t.integer  "year"
    t.datetime "date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "work_appearances", ["work_id"], :name => "index_work_appearances_on_work_id"

  create_table "works", :force => true do |t|
    t.string   "title"
    t.datetime "date"
    t.integer  "number"
    t.string   "variant"
    t.text     "metadata"
    t.integer  "edition_id"
    t.integer  "image_set_id"
    t.integer  "cross_edition_work_set_id"
    t.integer  "revises_work_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "works", ["cross_edition_work_set_id"], :name => "index_works_on_cross_edition_work_set_id"
  add_index "works", ["edition_id"], :name => "index_works_on_edition_id"
  add_index "works", ["image_set_id"], :name => "index_works_on_image_set_id"
  add_index "works", ["revises_work_id"], :name => "index_works_on_revises_work_id"

end

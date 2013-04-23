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

ActiveRecord::Schema.define(:version => 20130422152856) do

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
    t.integer  "owner_id"
    t.text     "description"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "editions", ["owner_id"], :name => "index_editions_on_owner_id"

  create_table "line_modifiers", :force => true do |t|
    t.integer  "work_id"
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

  create_table "page_group_pages", :force => true do |t|
    t.integer  "page_group_id"
    t.integer  "page_id"
    t.integer  "position"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "page_group_pages", ["page_group_id"], :name => "index_page_group_pages_on_page_group_id"
  add_index "page_group_pages", ["page_id"], :name => "index_page_group_pages_on_page_id"

  create_table "page_groups", :force => true do |t|
    t.string   "name"
    t.integer  "parent_group_id"
    t.boolean  "editable"
    t.text     "image_url"
    t.text     "metadata"
    t.integer  "edition_id"
    t.string   "type"
    t.integer  "position"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "page_groups", ["edition_id"], :name => "index_page_groups_on_edition_id"
  add_index "page_groups", ["parent_group_id"], :name => "index_page_groups_on_parent_group_id"

  create_table "pages", :force => true do |t|
    t.text     "image_url"
    t.text     "metadata"
    t.text     "credits"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "stanzas", :force => true do |t|
    t.integer  "work_id"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "stanzas", ["work_id"], :name => "index_stanzas_on_work_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
    t.integer  "year"
    t.datetime "date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "work_appearances", ["work_id"], :name => "index_work_appearances_on_work_id"

  create_table "work_group_works", :force => true do |t|
    t.integer  "work_group_id"
    t.integer  "work_id"
    t.integer  "position"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "work_group_works", ["work_group_id"], :name => "index_work_group_works_on_work_group_id"
  add_index "work_group_works", ["work_id"], :name => "index_work_group_works_on_work_id"

  create_table "work_groups", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.integer  "parent_group_id"
    t.integer  "edition_id"
    t.integer  "owner_id"
    t.integer  "position"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "work_groups", ["edition_id"], :name => "index_work_groups_on_edition_id"
  add_index "work_groups", ["owner_id"], :name => "index_work_groups_on_owner_id"
  add_index "work_groups", ["parent_group_id"], :name => "index_work_groups_on_parent_group_id"

  create_table "work_page_groups", :force => true do |t|
    t.integer  "work_id"
    t.integer  "page_group_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "work_page_groups", ["page_group_id"], :name => "index_work_page_groups_on_page_group_id"
  add_index "work_page_groups", ["work_id"], :name => "index_work_page_groups_on_work_id"

  create_table "works", :force => true do |t|
    t.string   "title"
    t.datetime "date"
    t.integer  "number"
    t.string   "variant"
    t.integer  "edition_id"
    t.integer  "page_group_id"
    t.text     "metadata"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "works", ["edition_id"], :name => "index_works_on_edition_id"
  add_index "works", ["page_group_id"], :name => "index_works_on_page_group_id"

end

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

ActiveRecord::Schema.define(version: 2020_07_01_095006) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "definitions", id: :serial, force: :cascade do |t|
    t.integer "word_variant_id"
    t.integer "number"
    t.text "definition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word_variant_id"], name: "index_definitions_on_word_variant_id"
  end

  create_table "editions", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "short_name", limit: 255
    t.string "citation", limit: 255
    t.string "author", limit: 255
    t.datetime "date"
    t.string "work_number_prefix", limit: 255
    t.float "completeness"
    t.text "description"
    t.integer "owner_id"
    t.integer "work_set_id"
    t.integer "image_set_id"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public"
    t.index ["completeness"], name: "index_editions_on_completeness"
    t.index ["image_set_id"], name: "index_editions_on_image_set_id"
    t.index ["owner_id"], name: "index_editions_on_owner_id"
    t.index ["parent_id"], name: "index_editions_on_parent_id"
    t.index ["work_set_id"], name: "index_editions_on_work_set_id"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.text "title"
    t.text "url"
    t.text "metadata"
    t.text "credits"
    t.integer "full_width"
    t.integer "full_height"
    t.integer "web_width"
    t.integer "web_height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "collection_id"
    t.index ["collection_id"], name: "index_images_on_collection_id"
  end

  create_table "line_modifiers", id: :serial, force: :cascade do |t|
    t.integer "work_id"
    t.integer "parent_id"
    t.integer "start_line_number"
    t.integer "start_address"
    t.integer "end_line_number"
    t.integer "end_address"
    t.string "type", limit: 255
    t.string "subtype", limit: 255
    t.text "original_characters"
    t.text "new_characters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_line_number"], name: "index_line_modifiers_on_end_line_number"
    t.index ["start_line_number"], name: "index_line_modifiers_on_start_line_number"
    t.index ["work_id"], name: "index_line_modifiers_on_work_id"
  end

  create_table "lines", id: :serial, force: :cascade do |t|
    t.integer "stanza_id"
    t.text "text"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stanza_id"], name: "index_lines_on_stanza_id"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.integer "notable_id"
    t.string "notable_type", limit: 255
    t.text "note"
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_notes_on_owner_id"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", limit: 255, null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "setts", id: :serial, force: :cascade do |t|
    t.text "name"
    t.text "metadata"
    t.string "type", limit: 255
    t.boolean "editable"
    t.integer "nestable_id"
    t.string "nestable_type", limit: 255
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level_order"
    t.string "ancestry", limit: 255
    t.boolean "is_leaf", default: true
    t.integer "ancestry_depth", default: 0
    t.index ["ancestry"], name: "index_setts_on_ancestry"
    t.index ["ancestry_depth"], name: "index_setts_on_ancestry_depth"
    t.index ["is_leaf"], name: "index_setts_on_is_leaf"
    t.index ["nestable_id"], name: "index_setts_on_nestable_id"
    t.index ["nestable_type"], name: "index_setts_on_nestable_type"
    t.index ["owner_id"], name: "index_setts_on_owner_id"
    t.index ["type"], name: "index_setts_on_type"
  end

  create_table "stanzas", id: :serial, force: :cascade do |t|
    t.integer "work_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["work_id"], name: "index_stanzas_on_work_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.integer "current_edition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "word_variants", id: :serial, force: :cascade do |t|
    t.integer "word_id"
    t.string "endings", limit: 255
    t.string "part_of_speech", limit: 255
    t.text "etymology"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "words", id: :serial, force: :cascade do |t|
    t.string "word", limit: 255
    t.string "sortable_word", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "work_appearances", id: :serial, force: :cascade do |t|
    t.integer "work_id"
    t.string "publication", limit: 255
    t.string "pages", limit: 255
    t.integer "year"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["work_id"], name: "index_work_appearances_on_work_id"
  end

  create_table "works", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.datetime "date"
    t.integer "number"
    t.string "variant", limit: 255
    t.boolean "secondary_source"
    t.text "metadata"
    t.integer "edition_id"
    t.integer "image_set_id"
    t.integer "revises_work_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["edition_id"], name: "index_works_on_edition_id"
    t.index ["image_set_id"], name: "index_works_on_image_set_id"
    t.index ["revises_work_id"], name: "index_works_on_revises_work_id"
  end

end

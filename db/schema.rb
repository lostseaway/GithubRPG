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

ActiveRecord::Schema.define(version: 20150707053445) do

  create_table "commit_files", force: :cascade do |t|
    t.integer  "commit_id",    limit: 4
    t.integer  "file_type_id", limit: 4
    t.integer  "additions",    limit: 4
    t.integer  "deletions",    limit: 4
    t.integer  "change",       limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "commit_files", ["commit_id"], name: "fk_rails_bc88627498", using: :btree
  add_index "commit_files", ["file_type_id"], name: "fk_rails_eae1ff663d", using: :btree

  create_table "commits", force: :cascade do |t|
    t.string   "sha",           limit: 255
    t.text     "message",       limit: 65535
    t.integer  "additions",     limit: 4
    t.integer  "deletions",     limit: 4
    t.datetime "commited_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "user_id",       limit: 4
    t.integer  "repository_id", limit: 4
    t.integer  "total",         limit: 4
  end

  add_index "commits", ["repository_id"], name: "fk_rails_a8299bc69b", using: :btree
  add_index "commits", ["user_id"], name: "fk_rails_409a66d7e3", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "event_id",      limit: 255
    t.string   "event_type",    limit: 255
    t.text     "message",       limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "user_id",       limit: 4
    t.integer  "repository_id", limit: 4
  end

  add_index "events", ["repository_id"], name: "fk_rails_022a085166", using: :btree
  add_index "events", ["user_id"], name: "fk_rails_0cb5590091", using: :btree

  create_table "file_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "lang_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.boolean  "check",      limit: 1
  end

  add_index "file_types", ["lang_id"], name: "fk_rails_9260015c6b", using: :btree

  create_table "lang_repositories", force: :cascade do |t|
    t.float    "byte",          limit: 24
    t.string   "match",         limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "lang_id",       limit: 4
    t.integer  "repository_id", limit: 4
  end

  add_index "lang_repositories", ["lang_id"], name: "fk_rails_bb5a56a2c6", using: :btree
  add_index "lang_repositories", ["repository_id"], name: "fk_rails_8691de46a4", using: :btree

  create_table "langs", force: :cascade do |t|
    t.string   "lang",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "repositories", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "full_name",   limit: 255
    t.text     "description", limit: 65535
    t.string   "match",       limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "lang_id",     limit: 4
  end

  add_index "repositories", ["lang_id"], name: "fk_rails_a7edf61eca", using: :btree

  create_table "user_repositories", force: :cascade do |t|
    t.string   "status",        limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "user_id",       limit: 4
    t.integer  "repository_id", limit: 4
  end

  add_index "user_repositories", ["repository_id"], name: "fk_rails_6c8c8eb319", using: :btree
  add_index "user_repositories", ["user_id"], name: "fk_rails_143c902d5d", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "login",       limit: 255
    t.string   "email",       limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "avatar_url",  limit: 255
    t.string   "match",       limit: 255
    t.string   "last_modify", limit: 255
    t.text     "location",    limit: 65535
    t.integer  "follower",    limit: 4
    t.string   "user_tag",    limit: 255
    t.string   "repo_tag",    limit: 255
  end

  add_foreign_key "commit_files", "commits"
  add_foreign_key "commit_files", "file_types"
  add_foreign_key "commits", "repositories"
  add_foreign_key "commits", "users"
  add_foreign_key "events", "repositories"
  add_foreign_key "events", "users"
  add_foreign_key "file_types", "langs"
  add_foreign_key "lang_repositories", "langs"
  add_foreign_key "lang_repositories", "repositories"
  add_foreign_key "repositories", "langs"
  add_foreign_key "user_repositories", "repositories"
  add_foreign_key "user_repositories", "users"
end

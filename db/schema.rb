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

ActiveRecord::Schema.define(:version => 20110907171727) do

  create_table "associations", :force => true do |t|
    t.string   "objectName"
    t.string   "roleName"
    t.integer  "cql_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attributes", :force => true do |t|
    t.string   "name"
    t.integer  "cql_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auth_service_urls", :force => true do |t|
    t.string   "url"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cql_objects", :force => true do |t|
    t.string   "objectName"
    t.string   "refid"
    t.integer  "endpoint_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "endpoints", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "predicates", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "queries", :force => true do |t|
    t.string   "object"
    t.string   "endpoint"
    t.string   "modifier"
    t.string   "term"
    t.integer  "predicate_id"
    t.string   "value"
    t.string   "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "cred",       :null => false
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

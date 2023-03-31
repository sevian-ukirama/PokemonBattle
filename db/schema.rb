# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_03_31_080934) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "battles", force: :cascade do |t|
    t.bigint "pokemon_1_id", null: false
    t.bigint "pokemon_2_id", null: false
    t.integer "turn_number", default: 1, null: false
    t.integer "status_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "winner_pokemon_id"
    t.index ["pokemon_1_id"], name: "index_battles_on_pokemon_1_id"
    t.index ["pokemon_2_id"], name: "index_battles_on_pokemon_2_id"
    t.index ["winner_pokemon_id"], name: "index_battles_on_winner_pokemon_id"
  end

  create_table "moves", force: :cascade do |t|
    t.string "name"
    t.integer "type_id"
    t.integer "maximum_pp"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "power"
    t.integer "accuracy"
    t.integer "usage_pp", default: 1
    t.integer "status_effect_id"
    t.index ["name"], name: "index_moves_on_name", unique: true
  end

  create_table "pokemon_moves", force: :cascade do |t|
    t.bigint "pokemon_id", null: false
    t.bigint "move_id", null: false
    t.integer "row_order", default: 1, null: false
    t.integer "current_pp"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["move_id"], name: "index_pokemon_moves_on_move_id"
    t.index ["pokemon_id", "move_id"], name: "index_pokemon_moves_on_pokemon_id_and_move_id", unique: true
    t.index ["pokemon_id"], name: "index_pokemon_moves_on_pokemon_id"
  end

  create_table "pokemons", force: :cascade do |t|
    t.string "name"
    t.integer "current_hp"
    t.integer "maximum_hp"
    t.integer "speed"
    t.integer "attack"
    t.integer "defense"
    t.integer "special_attack"
    t.integer "special_defense"
    t.integer "type_1_id"
    t.integer "type_2_id"
    t.integer "status_id", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image_url"
    t.index ["name"], name: "index_pokemons_on_name", unique: true
  end

  add_foreign_key "battles", "pokemons", column: "pokemon_1_id"
  add_foreign_key "battles", "pokemons", column: "pokemon_2_id"
  add_foreign_key "battles", "pokemons", column: "winner_pokemon_id"
  add_foreign_key "pokemon_moves", "moves"
  add_foreign_key "pokemon_moves", "pokemons"
end

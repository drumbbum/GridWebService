class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.string :object
      t.string :endpoint
      t.string :modifier
      t.string :term
      t.integer :predicate_id
      t.string :value
      t.string :description
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :queries
  end
end

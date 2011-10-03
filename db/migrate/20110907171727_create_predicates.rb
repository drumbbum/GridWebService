class CreatePredicates < ActiveRecord::Migration
  def self.up
    create_table :predicates do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :predicates
  end
end

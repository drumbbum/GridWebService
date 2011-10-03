class CreateCqlObjects < ActiveRecord::Migration
  def self.up
    create_table :cql_objects do |t|
      t.string :objectName
      t.string :refid
      t.integer :endpoint_id

      t.timestamps
    end
  end

  def self.down
    drop_table :cql_objects
  end
end

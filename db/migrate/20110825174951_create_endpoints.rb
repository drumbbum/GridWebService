class CreateEndpoints < ActiveRecord::Migration
  def self.up
    create_table :endpoints do |t|
      t.string :name
      t.string :address
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :endpoints
  end
end

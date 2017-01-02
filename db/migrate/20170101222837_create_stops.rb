class CreateStops < ActiveRecord::Migration[5.0]
  def change
    create_table :stops do |t|
      t.integer :schedule_id, :null => false
      t.string :guid, :null => false
      t.string :short_name
      t.string :name
      t.string :description
      t.decimal :latitude, :precision => 10, :scale => 8
      t.decimal :longitude, :precision => 11, :scale => 8
      t.string :zone_guid
      t.string :url
      t.integer :location_code, :length => 1
      t.string :parent_guid
      t.string :timezone
      t.integer :wheelchair_code, :length => 1

      t.timestamps
    end

    add_index :stops, [:schedule_id, :guid], :unique => true
    add_index :stops, :schedule_id
    add_index :stops, :guid
    add_index :stops, :zone_guid
    add_index :stops, :location_code
    add_index :stops, :parent_guid
    add_index :stops, :wheelchair_code
  end
end

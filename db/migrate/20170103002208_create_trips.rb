class CreateTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :trips do |t|
      t.integer :schedule_id, :null => false
      t.string :guid, :null => false
      t.string :route_guid
      t.string :service_guid
      t.string :headsign
      t.string :short_name
      t.integer :direction_code, :length => 1
      t.string :block_guid
      t.string :shape_guid
      t.integer :wheelchair_code, :length => 1
      t.integer :bicycle_code, :length => 1

      t.timestamps
    end

    add_index :trips, [:schedule_id, :guid], :unique => true
    add_index :trips, :schedule_id
    add_index :trips, :guid
    add_index :trips, :direction_code
  end
end

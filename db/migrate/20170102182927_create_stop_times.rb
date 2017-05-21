class CreateStopTimes < ActiveRecord::Migration[5.0]
  def change
    create_table :stop_times do |t|
      t.integer :schedule_id, :null => false
      t.string :trip_guid, :null => false
      t.string :stop_guid, :null => false
      t.integer :stop_sequence
      t.string :arrival_time #TODO: t.time
      t.string :departure_time #TODO: t.time

      t.string :headsign
      t.integer :pickup_code, :length => 1
      t.integer :dropoff_code, :length => 1
      t.integer :distance
      t.integer :code, :length => 1

      t.timestamps
    end

    add_index :stop_times, [:schedule_id, :trip_guid, :stop_guid], :unique => true
    add_index :stop_times, :schedule_id
    add_index :stop_times, :trip_guid
    add_index :stop_times, :stop_guid
    add_index :stop_times, :stop_sequence
    add_index :stop_times, :code
  end
end

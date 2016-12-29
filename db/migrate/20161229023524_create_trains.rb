class CreateTrains < ActiveRecord::Migration[5.0]
  def change
    create_table :trains do |t|
      t.string :origin, :length => 25
      t.datetime :origin_departure
      t.string :destination, :length => 25
      t.datetime :destination_arrival

      t.timestamps
    end
  end
end

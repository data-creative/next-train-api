class CreateCalendarDates < ActiveRecord::Migration[5.0]
  def change
    create_table :calendar_dates do |t|
      t.integer :schedule_id, :null => false
      t.string :service_id
      t.date :exception_date
      t.integer :exception_code, :length => 1

      t.timestamps
    end

    add_index :calendar_dates, [:schedule_id, :service_id, :exception_date], :unique => true, :name => 'calendar_dates_ck'
    add_index :calendar_dates, :schedule_id
    add_index :calendar_dates, :service_id
    add_index :calendar_dates, :exception_date
    ### add_index :calendar_dates, [:schedule_id, :service_id, :exception_date, :exception_code], :unique => true, :name => 'calendar_dates_code_ck'
    add_index :calendar_dates, :exception_code
  end
end

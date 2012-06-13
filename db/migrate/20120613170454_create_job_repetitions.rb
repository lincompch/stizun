class CreateJobRepetitions < ActiveRecord::Migration
  def change
    create_table :job_repetitions do |t|
      t.integer :dow
      t.integer :dom
      t.integer :month
      t.integer :hour
      t.integer :minute

      t.timestamps
    end
  end
end

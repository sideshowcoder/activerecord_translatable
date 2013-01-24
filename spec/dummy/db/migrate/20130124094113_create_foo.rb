class CreateFoo < ActiveRecord::Migration
  def change
    create_table :foos do |t|
      t.timestamps
    end
  end
end

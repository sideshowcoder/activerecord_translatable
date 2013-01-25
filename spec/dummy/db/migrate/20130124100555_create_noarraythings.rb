class CreateNoarraythings < ActiveRecord::Migration
  def change
    create_table :noarraythings do |t|
      t.string :locales

      t.timestamps
    end
  end
end

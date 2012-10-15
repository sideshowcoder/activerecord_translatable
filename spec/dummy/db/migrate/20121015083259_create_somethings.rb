class CreateSomethings < ActiveRecord::Migration
  def change
    create_table :somethings do |t|
      t.string_array :locales
      t.timestamps
    end
  end
end

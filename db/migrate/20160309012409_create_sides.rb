class CreateSides < ActiveRecord::Migration[4.2]
  def change
    create_table :sides do |t|
      t.references :design, index: true, foreign_key: true
      t.integer :order
      t.integer :orientation
      t.integer :margin
      t.integer :width
      t.integer :height

      t.timestamps null: false
    end
  end
end

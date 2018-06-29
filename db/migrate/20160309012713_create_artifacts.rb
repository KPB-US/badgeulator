class CreateArtifacts < ActiveRecord::Migration[4.2]
  def change
    create_table :artifacts do |t|
      t.references :side, index: true, foreign_key: true
      t.string :name
      t.integer :order
      t.string :description
      t.string :value

      t.timestamps null: false
    end
  end
end

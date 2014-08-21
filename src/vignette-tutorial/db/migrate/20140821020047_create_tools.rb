class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.string :name
      t.integer :classifier_id
      t.string :image

      t.timestamps
    end
  end
end

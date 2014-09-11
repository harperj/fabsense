class CreateTutorialIngredients < ActiveRecord::Migration
  def change
    create_table :tutorial_ingredients do |t|
      t.integer :tutorial_id
      t.integer :tool_id
      t.integer :order_marker

      t.timestamps
    end
  end
end

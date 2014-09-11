class Tutorial < ActiveRecord::Base
	has_many :tutorial_ingredients

	def ingredients
		TutorialIngredient.where("tutorial_id = ?", self[:id])
	end
end

class TutorialIngredient < ActiveRecord::Base
	belongs_to :tutorial
	belongs_to :tool
end

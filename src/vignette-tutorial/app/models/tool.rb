class Tool < ActiveRecord::Base
	mount_uploader :image, PictureUploader
	has_many :tutorial_ingredients
end

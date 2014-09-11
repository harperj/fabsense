class TutorialIngredientsController < ApplicationController
  before_action :set_tutorial_ingredient, only: [:show, :edit, :update, :destroy]

  # GET /tutorial_ingredients
  # GET /tutorial_ingredients.json
  def index
    @tutorial_ingredients = TutorialIngredient.all
  end

  # GET /tutorial_ingredients/1
  # GET /tutorial_ingredients/1.json
  def show
  end

  # GET /tutorial_ingredients/new
  def new
    @tutorial_ingredient = TutorialIngredient.new
  end

  # GET /tutorial_ingredients/1/edit
  def edit
  end

  # POST /tutorial_ingredients
  # POST /tutorial_ingredients.json
  def create
    @tutorial_ingredient = TutorialIngredient.new(tutorial_ingredient_params)

    respond_to do |format|
      if @tutorial_ingredient.save
        format.html { redirect_to @tutorial_ingredient, notice: 'Tutorial ingredient was successfully created.' }
        format.json { render :show, status: :created, location: @tutorial_ingredient }
      else
        format.html { render :new }
        format.json { render json: @tutorial_ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tutorial_ingredients/1
  # PATCH/PUT /tutorial_ingredients/1.json
  def update
    respond_to do |format|
      if @tutorial_ingredient.update(tutorial_ingredient_params)
        format.html { redirect_to @tutorial_ingredient, notice: 'Tutorial ingredient was successfully updated.' }
        format.json { render :show, status: :ok, location: @tutorial_ingredient }
      else
        format.html { render :edit }
        format.json { render json: @tutorial_ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tutorial_ingredients/1
  # DELETE /tutorial_ingredients/1.json
  def destroy
    @tutorial_ingredient.destroy
    respond_to do |format|
      format.html { redirect_to tutorial_ingredients_url, notice: 'Tutorial ingredient was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tutorial_ingredient
      @tutorial_ingredient = TutorialIngredient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tutorial_ingredient_params
      params.require(:tutorial_ingredient).permit(:tutorial_id, :tool_id, :order_marker)
    end
end

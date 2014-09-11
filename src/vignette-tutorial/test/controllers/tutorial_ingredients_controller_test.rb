require 'test_helper'

class TutorialIngredientsControllerTest < ActionController::TestCase
  setup do
    @tutorial_ingredient = tutorial_ingredients(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tutorial_ingredients)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tutorial_ingredient" do
    assert_difference('TutorialIngredient.count') do
      post :create, tutorial_ingredient: { order_marker: @tutorial_ingredient.order_marker, tool_id: @tutorial_ingredient.tool_id, tutorial_id: @tutorial_ingredient.tutorial_id }
    end

    assert_redirected_to tutorial_ingredient_path(assigns(:tutorial_ingredient))
  end

  test "should show tutorial_ingredient" do
    get :show, id: @tutorial_ingredient
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tutorial_ingredient
    assert_response :success
  end

  test "should update tutorial_ingredient" do
    patch :update, id: @tutorial_ingredient, tutorial_ingredient: { order_marker: @tutorial_ingredient.order_marker, tool_id: @tutorial_ingredient.tool_id, tutorial_id: @tutorial_ingredient.tutorial_id }
    assert_redirected_to tutorial_ingredient_path(assigns(:tutorial_ingredient))
  end

  test "should destroy tutorial_ingredient" do
    assert_difference('TutorialIngredient.count', -1) do
      delete :destroy, id: @tutorial_ingredient
    end

    assert_redirected_to tutorial_ingredients_path
  end
end

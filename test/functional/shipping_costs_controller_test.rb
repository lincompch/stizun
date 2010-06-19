require 'test_helper'

class ShippingCostsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shipping_costs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shipping_cost" do
    assert_difference('ShippingCost.count') do
      post :create, :shipping_cost => { }
    end

    assert_redirected_to shipping_cost_path(assigns(:shipping_cost))
  end

  test "should show shipping_cost" do
    get :show, :id => shipping_costs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => shipping_costs(:one).to_param
    assert_response :success
  end

  test "should update shipping_cost" do
    put :update, :id => shipping_costs(:one).to_param, :shipping_cost => { }
    assert_redirected_to shipping_cost_path(assigns(:shipping_cost))
  end

  test "should destroy shipping_cost" do
    assert_difference('ShippingCost.count', -1) do
      delete :destroy, :id => shipping_costs(:one).to_param
    end

    assert_redirected_to shipping_costs_path
  end
end

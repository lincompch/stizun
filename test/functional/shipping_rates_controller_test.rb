require 'test_helper'

class ShippingRatesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shipping_rates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shipping_rate" do
    assert_difference('ShippingRate.count') do
      post :create, :shipping_rate => { }
    end

    assert_redirected_to shipping_rate_path(assigns(:shipping_rate))
  end

  test "should show shipping_rate" do
    get :show, :id => shipping_rates(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => shipping_rates(:one).to_param
    assert_response :success
  end

  test "should update shipping_rate" do
    put :update, :id => shipping_rates(:one).to_param, :shipping_rate => { }
    assert_redirected_to shipping_rate_path(assigns(:shipping_rate))
  end

  test "should destroy shipping_rate" do
    assert_difference('ShippingRate.count', -1) do
      delete :destroy, :id => shipping_rates(:one).to_param
    end

    assert_redirected_to shipping_rates_path
  end
end

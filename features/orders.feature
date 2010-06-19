Feature: Orders as collections of items

  Background: Shipping rates and payment methods exist
    Given there is a shipping rate called "Alltron AG" with the following costs:
    |weight_min|weight_max|price|tax_percentage|
    |         0|      1000|   10|           7.6|
    And there is a payment method called "Prepay" which does not allow direct shipping and is the default
    And there is a payment method called "Invoice" which allows direct shipping


  Scenario: Find the weight of an order
    Given an order with the following products:
    |quantity|name  |weight|direct_shipping|
    |       1|Laptop|   0.9|           true|
    |       4|Fish  |   1.0|           true|
    |      18|Foo   |   2.0|           true|
    When I calculate the shipping rate for the order
    Then the order's total weight should be 40.9
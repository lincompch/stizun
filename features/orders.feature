Feature: Orders as collections of items

  Background: Shipping rates and payment methods exist
    Given there is a shipping rate called "Alltron AG" with the following costs:
    |weight_min|weight_max|price|tax_percentage|
    |         0|      1000|   10|           8.0|
    |      1001|      2000|   20|           8.0|
    And there are the following suppliers:
    |name|shipping_rate_name|
    |Alltron AG|Alltron AG|
    And there is a payment method called "Prepay" which is the default
    And there is a payment method called "Invoice"


  Scenario: Find the weight of an order
    Given an order with the following products:
    |quantity|name  |weight|direct_shipping|tax_class |supplier  |purchase_price|margin_percentage|
    |       1|Laptop|   0.90|           true|MwSt 8.0%|Alltron AG|           100|              5.0|
    |       4|Fish  |   1.00|           true|MwSt 8.0%|Alltron AG|           100|              5.0|
    |      18|Foo   |   2.00|           true|MwSt 8.0%|Alltron AG|           100|              5.0|
    When I calculate the shipping rate for the order
    Then the order's total weight should be 40.9
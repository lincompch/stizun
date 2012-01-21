Feature: Orders as collections of items

  Background: Shipping rates and payment methods exist
      And there is a default shipping shipping calculator of type ShippingCalculatorBasedOnWeight called "Alltron AG" with the following costs:
    |weight_min|weight_max|price|
    |         0|      1000|   10|
    |      1001|      2000|   20|
    And there are the following suppliers:
    |name|
    |Alltron AG|
    And there is a payment method called "Prepay" which is the default
    And there is a payment method called "Invoice"


  Scenario: Find the weight of an order
    Given an order with the following products:
    |quantity|name  |weight|tax_class |supplier  |purchase_price|margin_percentage|manufacturer_product_code|
    |       1|Laptop|   0.90|MwSt 8.0%|Alltron AG|           100|              5.0|123|
    |       4|Fish  |   1.00|MwSt 8.0%|Alltron AG|           100|              5.0|456|
    |      18|Foo   |   2.00|MwSt 8.0%|Alltron AG|           100|              5.0|789|
    Then the order's total weight should be 40.9

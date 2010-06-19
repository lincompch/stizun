Feature: Shipping rate calculation and package count
  As a store owner, I want my store to calculate shipping accurately, both to
  be fair to my customers and to make sure I don't lose money on shipping.

    Background: Shipping rates exist
      Given there is a shipping rate called "Alltron AG" with the following costs:
        |weight_min|weight_max|price|tax_percentage|
        |         0|      1000|   10|           7.6|
        |      1001|      2000|   20|           7.6|
        |      2001|      3000|   30|           7.6|
        |      3001|      4000|   40|           7.6|
        |      4001|      5000|   50|           7.6|
      And there is a shipping rate called "Swiss Post" with the following costs:
        |weight_min|weight_max|price|tax_percentage|
        |         0|      1000|   15|           7.6|
        |      1001|      2000|   25|           7.6|
        |      2001|      3000|   35|           7.6|
        |      3001|      4000|   45|           7.6|
        |      4001|      5000|   55|           7.6|
      And there is a payment method called "Prepay" which does not allow direct shipping and is the default
      And there is a payment method called "Invoice" which allows direct shipping

    Scenario: Calculate simple shipping for one product
      Given an order with the following products:
        |quantity|name  |weight|direct_shipping|
        |       1|Laptop|   0.9|           true|
      When I calculate the shipping rate for the order
      Then the order's total weight should be 0.9
      And the order's outgoing shipping price should be 8.608
      And the order's outgoing package count should be 1


    Scenario: Calculate simple shipping for multiple products
      Given an order with the following products:
        |quantity|name  |weight|direct_shipping|
        |       1|Laptop|   0.9|           true|
        |       4|Fish  |   1.0|           true|
      When I calculate the shipping rate for the order
      Then the order's total weight should be 4.9
      And the order's outgoing shipping price should be 10.76
      And the order's outgoing package count should be 1
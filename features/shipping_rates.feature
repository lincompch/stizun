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
      And the direct shipping fees for shipping rate "Alltron AG" are "100.0"
      And there is a shipping rate called "Swiss Post" with the following costs:
        |weight_min|weight_max|price|tax_percentage|
        |         0|      1000|   15|           7.6|
        |      1001|      2000|   25|           7.6|
        |      2001|      3000|   35|           7.6|
        |      3001|      4000|   45|           7.6|
        |      4001|      5000|   55|           7.6|
      And the direct shipping fees for shipping rate "Swiss Post" are "0.0"
      And there is a payment method called "Prepay" which does not allow direct shipping and is the default
      And there is a payment method called "Invoice" which allows direct shipping
      And there are the following suppliers:
        |name|shipping_rate_name|
        |Alltron AG|Alltron AG|
 
    Scenario: Calculate direct shipping for one product
      Given an order with the following products:
        |quantity|name  |weight|direct_shipping|supplier  |
        |       1|Laptop|   0.9|           true|Alltron AG|
      And the order's payment method is "Invoice"
      When I calculate the shipping rate for the order
      Then the order's total weight should be 0.9
      And the order's outgoing shipping price should be 118.36
      And the order's incoming shipping price should be 0.0
      And the order's outgoing package count should be 1

    Scenario: Calculate direct shipping for multiple products
      Given an order with the following products:
        |quantity|name  |weight|direct_shipping|supplier  |
        |       1|Laptop|   0.9|           true|Alltron AG|
        |       4|Fish  |   1.0|           true|Alltron AG|
      And the order's payment method is "Invoice"
      When I calculate the shipping rate for the order
      Then the order's total weight should be 4.9
      And the order's outgoing shipping price should be 161.4
      And the order's incoming shipping price should be 0.0
      And the order's outgoing package count should be 1

    Scenario: Calculate indirect shipping for multiple products
      Given an order with the following products:
        |quantity|name  |weight|direct_shipping|supplier  |
        |       1|Laptop|   0.9|           true|Alltron AG|
        |       4|Fish  |   1.0|           true|Alltron AG|
      When I calculate the shipping rate for the order
      Then the order's total weight should be 4.9
      And the order's outgoing shipping price should be 10.76 
      And the order's incoming shipping price should be 53.80 
      And the order's outgoing package count should be 1


    Scenario: Calculate taxes on shipping for multiple products
      Given an order with the following products:
        |quantity|name  |weight|direct_shipping|supplier  |
        |       2|Laptop|   0.9|           true|Alltron AG|
        |       8|Fish  |   1.0|           true|Alltron AG|
      When I calculate the shipping rate for the order
      Then the order's total weight should be 9.8 
      And the order's outgoing shipping price should be 13.988 
      And the order's incoming shipping price should be 107.6
      And the order's outgoing package count should be 1
      And the order's incoming package count should be 2
      And the order's taxes should be 8.588 

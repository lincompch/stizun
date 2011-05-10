Feature: Shipping rate calculation and package count
  As a store owner, I want my store to calculate shipping accurately, both to
  be fair to my customers and to make sure I don't lose money on shipping.

    Background: Shipping rates exist
      Given there is a shipping rate called "Alltron AG" with the following costs:
        |weight_min|weight_max|price|tax_percentage|
        |         0|      1000|   10|           8.0|
        |      1001|      2000|   20|           8.0|
        |      2001|      3000|   30|           8.0|
        |      3001|      4000|   40|           8.0|
        |      4001|      5000|   50|           8.0|
      And the direct shipping fees for shipping rate "Alltron AG" are "100.0" with tax percentage 8.0
      And there is a shipping rate called "Swiss Post" with the following costs:
        |weight_min|weight_max|price|tax_percentage|
        |         0|      1000|   15|           8.0|
        |      1001|      2000|   25|           8.0|
        |      2001|      3000|   35|           8.0|
        |      3001|      4000|   45|           8.0|
        |      4001|      5000|   55|           8.0|
      And the direct shipping fees for shipping rate "Swiss Post" are "0.0" with tax percentage 8.0
      And there is a payment method called "Prepay" which is the default
      And there is a payment method called "Invoice"
      And there are the following suppliers:
        |name|shipping_rate_name|
        |Alltron AG|Alltron AG|

    @work
    Scenario: Calculate direct shipping for one product
      Given an order with the following products:
        |quantity|name  |weight|direct_shipping|supplier  |purchase_price|
        |       1|Laptop|   0.9|           true|Alltron AG|120|
      And the order's payment method is "Invoice"
      When I calculate the shipping rate for the order
      Then the order's total weight should be 0.9
      And the order's outgoing shipping price should be 118.80

    Scenario: Calculate direct shipping for multiple products
      Given an order with the following products:
        |quantity|name  |weight|direct_shipping|supplier  |
        |       1|Laptop|   0.9|           true|Alltron AG|
        |       4|Fish  |   1.0|           true|Alltron AG|
      And the order's payment method is "Invoice"
      When I calculate the shipping rate for the order
      Then the order's total weight should be 4.9
      And the order's shipping taxes should be 12.00
      And the order's total shipping price should be 162.00

    Scenario: Calculate indirect shipping for multiple products
      Given an order with the following products:
        |quantity|name  |weight|direct_shipping|supplier  |
        |       1|Laptop|   0.9|           true|Alltron AG|
        |       4|Fish  |   1.0|          false|Alltron AG|
      When I calculate the shipping rate for the order
      Then the order's total weight should be 4.9
      And the order's shipping taxes should be 4.816
      And the order's total shipping price should be 65.016


#    Scenario: Calculate taxes on indirect shipping for multiple products
#      Given an order with the following products:
#        |quantity|name  |weight|direct_shipping|supplier  |
#        |       2|Laptop|   0.9|           true|Alltron AG|
#        |       8|Fish  |   1.0|          false|Alltron AG|
#      When I calculate the shipping rate for the order
#      Then the order's total weight should be 9.8 
#      And the order's outgoing shipping price should be 11.988
#      And the order's shipping taxes should be 8.888

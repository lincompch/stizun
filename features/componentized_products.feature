Feature: Create componentized products
  Componentized products consist of a product that has one or more
  supply items. The product price is created from the sum of
  the component prices (and their quantities)

  Background: Set up some necessary things
      Given a category named "PCs" exists
      And there is a configuration item named "currency" with value "CHF"
      And there is a user with e-mail address "admin@something.com" and password "foobar"
      And a tax class named "MwSt 8.0%" with the percentage 8.0%
      And the user group "Admins" exists
      And the user group "Admins" has admin permissions
      And the user is member of the group "Admins"
      And I log in with e-mail address "admin@something.com" and password "foobar"
      And there is a default shipping shipping calculator of type ShippingCalculatorBasedOnWeight called "Alltron AG" with the following costs:
        |weight_min|weight_max|price|
        |         0|      1000|   10|
        |      1001|      2000|   20|
        |      2001|      3000|   30|
        |      3001|      4000|   40|
        |      4001|      5000|   50|
      And there are the following suppliers:
        |name|
        |Alltron AG|
      And there is a payment method called "Prepay" which is the default
      And there are the following supply items:
      |product_code|weight|price|stock|name         |supplier   |
      |        1289|  0.54|40.38|    4|Big Screen   |Alltron AG | 
      |        2313|  0.06|24.49|    3|1 GB RAM DIMM|Alltron AG |
      |        3188|  0.28|36.90|   55|Weak CPU     |Alltron AG |
      |        5509|  0.08|19.80|  545|Keyboard     |Alltron AG |
      |        6591|  0.07|20.91|    2|Mouse        |Alltron AG |
        
      
  Scenario: Create a componentized product (not full-stack)
  
  Scenario: Create a componentized product (full-stack)

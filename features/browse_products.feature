Feature: Browse products

  So that a customer can buy something
  They need to be able to browse our products

    Background: Set up some necessary things
      Given a category named "Notebooks" exists
      And there is a configuration item named "currency" with value "CHF"
      And there is a user with e-mail address "admin@something.com" and password "foobar"
      And a tax class named "MwSt 8.0%" with the percentage 8.0%
      And the user group "Admins" exists
      And the user group "Admins" has admin permissions
      And the user is member of the group "Admins"
      And I log in with e-mail address "admin@something.com" and password "foobar"
      And there is a shipping rate called "Alltron AG" with the following costs:
        |weight_min|weight_max|price|tax_percentage|
        |         0|      1000|   10|           8.0|
        |      1001|      2000|   20|           8.0|
        |      2001|      3000|   30|           8.0|
        |      3001|      4000|   40|           8.0|
        |      4001|      5000|   50|           8.0|
      And there are the following suppliers:
        |name|shipping_rate_name|
        |Alltron AG|Alltron AG|
      And there is a payment method called "Prepay" which is the default

    Scenario: Browse all products
      Given the following products exist(table):
      |name        |category               |supplier  |purchase_price|direct_shipping|manufacturer_product_code|
      |Foobar 2000 |Metasyntactic Variables|Alltron AG|100.0         |true           |foo1                     |
      |Fish        |Animals                |Alltron AG|100.0         |true           |foo2                     |
      |Defender    |Arcade games           |Alltron AG|100.0         |true           |foo3                     |
      When I view the product list
      Then I should see a product named "Foobar 2000"
      And I should see a product named "Fish"
      And I should see a product named "Defender"

    Scenario: Browse products in a category
      Given the following products exist(table):
      |name        |category               |supplier  |purchase_price|direct_shipping|manufacturer_product_code|
      |Foobar 2000 |Metasyntactic Variables|Alltron AG|100.0         |true           |foo1                     |
      |Fish        |Animals                |Alltron AG|100.0         |true           |foo2                     |
      |Defender    |Arcade games           |Alltron AG|100.0         |true           |foo3                     |
      When I view the category "Animals"
      Then I should see a product named "Fish"
      And I should not see a product named "Defender"

    Scenario: View single product


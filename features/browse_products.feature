Feature: Browse products

  So that a customer can buy something
  They need to be able to browse our products

    Background: Set up some necessary things
      Given a category named "Notebooks" exists
      And there is a user with e-mail address "admin@something.com" and password "foobar"
      And a tax class named "MwSt 7.6%" with the percentage 7.6%
      And the user group "Admins" exists
      And the user group "Admins" has admin permissions
      And the user is member of the group "Admins"
      And I log in with e-mail address "admin@something.com" and password "foobar"
      And there is a shipping rate called "Alltron AG" with the following costs:
        |weight_min|weight_max|price|tax_percentage|
        |         0|      1000|   10|           7.6|
        |      1001|      2000|   20|           7.6|
        |      2001|      3000|   30|           7.6|
        |      3001|      4000|   40|           7.6|
        |      4001|      5000|   50|           7.6|
      And there are the following suppliers:
        |name|shipping_rate_name|
        |Alltron AG|Alltron AG|
      And there is a payment method called "Prepay" which does not allow direct shipping and is the default

    @javascript      
    Scenario: Create product
      When I create a product called "Lenovo T400"
      And I wait for a fancybox to appear
      And fill in the product description "Some laptop"
      And I fill in the purchase price 100.0
      And I fill in the margin percentage 5.0
      And I fill in the weight 5.0
      And I select "Alltron AG" from "Supplier" within "#fancybox-frame"
      And I select the tax class "MwSt 7.6%"
      And I assign the product to the category "Notebooks"
      And I click the create button
      Then there should be a product called "Lenovo T400"
      And the category "Notebooks" should contain a product named "Lenovo T400"
      
    @javascript 
    Scenario: Forget assigning a tax class when creating a product
      When I create a product called "Lenovo T400"
      And I wait for a fancybox to appear
      And fill in the product description "Some laptop"
      And I fill in the purchase price 100.0
      And I fill in the weight 5.0
      And I select "Alltron AG" from "Supplier" within "#fancybox-frame"
      And I fill in the margin percentage 5.0
      And I click the create button
      Then I should see an error message inside the fancybox
      
    Scenario: Browse all products
      Given a product named "Foobar 2000" in the category "Metasyntactic Variables"
      And a product named "Fish" in the category "Animals"
      And a product named "Defender" in the category "Arcade games"
      When I view the product list
      Then I should see a product named "Foobar 2000"
      And I should see a product named "Fish"
      And I should see a product named "Defender"

    Scenario: Browse products in a category
      Given a product named "Foobar 2000" in the category "Metasyntactic Variables"
      And a product named "Fish" in the category "Animals"
      And a product named "Defender" in the category "Arcade games"
      When I view the category "Animals"
      Then I should see a product named "Fish"
      And I should not see a product named "Defender"

    Scenario: View single product
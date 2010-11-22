Feature: Browse products

  So that a customer can buy something
  They need to be able to browse our products

    Background: Log in as admin
      Given a category named "Notebooks" exists
      Given there is a user with e-mail address "admin@something.com" and password "foobar"
      And the user group "Admins" exists
      And the user group "Admins" has admin permissions
      And the user is member of the group "Admins"
      And I log in with e-mail address "admin@something.com" and password "foobar"
      
    @javascript      
    Scenario: Create product
      Given a tax class named "MwSt 7.6%" with the percentage 7.6%
      When I create a product called "Lenovo T400"
      And I wait for a fancybox to appear
      And fill in the product description "Some laptop"
      And I fill in the purchase price 100.0
      And I fill in the margin percentage 5.0
      And I fill in the weight 5.0
      And I select the tax class "MwSt 7.6%"
      And I click the create button
      Then there should be a product called "Lenovo T400"

    Scenario: Assign product to category
      And a product named "Lenovo T400"
      When I assign the product to the category "Notebooks"
      Then the category "Notebooks" should contain a product named "Lenovo T400"
      
    @javascript 
    Scenario: Forget assigning a tax class when creating a product
      When I create a product called "Lenovo T400"
      And I wait for a fancybox to appear
      And fill in the product description "Some laptop"
      And I fill in the purchase price 100.0
      And I fill in the weight 5.0
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
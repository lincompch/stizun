Feature: Ordering

  So that a customer can buy something
  They need to be able to check out things and fill in an order form

    Scenario: Add to cart
      Given a product named "Fish" in the category "Animals"
      When I view the category "Animals"
      And I add the store's only product to my cart
      Then my cart should contain a product named "Fish"

    Scenario: Add to cart multiple times
      Given a product named "Fish" in the category "Animals"
      When I view the category "Animals"
      And I add the store's only product to my cart 4 times
      Then my cart should contain a product named "Fish" 4 times

    Scenario: Add to cart different items
      Given I have ordered some stuff
      Then my cart should contain some stuff

    Scenario: View checkout
      Given I have ordered some stuff
      When I visit the checkout
      Then I should see an order summary

    Scenario: Complete checkout
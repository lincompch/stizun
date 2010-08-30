Feature: Price calculation on products, orders, invoices

  So that the store gives correct prices to customers
  As a customer
  I want to see correct prices for all products

  Background: A system configuration needs to be here
    Given there is a configuration item named "tax_booker_class_name" with value "TaxBookers::SwissTaxBooker"

    Scenario: Show price based on purchase price plus margin calculation and taxes
      Given a product
      And a tax class named "MwSt 7.6%" with the percentage 7.6%
      When I set the purchase price to 100.0
      And I set the margin percentage to 5.0
      And I set the tax class to "MwSt 7.6%"
      Then the product price should be 112.98
      And the rounded price should be 113.0
      And the absolute margin should be 5.0
      And the taxes should be 7.98

    Scenario: Show price based on absolutely defined sales price and taxes
      Given a product
      And a tax class named "MwSt 7.6%" with the percentage 7.6%
      When I set the purchase price to 97.10
      And I set the absolute sales price to 107.60
      And I set the tax class to "MwSt 7.6%"
      Then the product price should be 107.6
      And the rounded price should be 107.60
      And the absolute margin should be 2.90
      And the taxes should be 7.6

    Scenario: Show price based on absolutely defined sales price and taxes with rounding down to 0.5
      Given a product
      And a tax class named "MwSt 7.6%" with the percentage 7.6%
      When I set the purchase price to 100.00
      And I set the absolute sales price to 120.52
      And I set the tax class to "MwSt 7.6%"
      Then the product price should be 120.52
      And the rounded price should be 120.50
      And the absolute margin should be roughly 12.0074349442379182156133828996
      And the taxes should be roughly 8.5125650557620817843866171004

    Scenario: Show price based on absolutely defined sales price and taxes with rounding up to 0.5
      Given a product
      And a tax class named "MwSt 7.6%" with the percentage 7.6%
      When I set the purchase price to 100.00
      And I set the absolute sales price to 120.58
      And I set the tax class to "MwSt 7.6%"
      Then the product price should be 120.58
      And the rounded price should be 120.60
      And the absolute margin should be roughly 12.0631970260223048327137546466
      And the taxes should be roughly 8.5168029739777951672862453534

    Scenario: Show price based on absolutely defined sales price and taxes without need for rounding to 0.5
      Given a product
      And a tax class named "MwSt 7.6%" with the percentage 7.6%
      When I set the purchase price to 100.00
      And I set the absolute sales price to 120.55
      And I set the tax class to "MwSt 7.6%"
      Then the product price should be 120.55
      And the rounded price should be 120.55
      And the absolute margin should be roughly 12.03531598513011152416356877348
      And the taxes should be roughly 8.51468401486988847583643122652



    Scenario: Show price based on more complicated absolutely defined sales price and taxes
      Given a product
      And a tax class named "MwSt 7.6%" with the percentage 7.6%
      When I set the purchase price to 296.73
      And I set the absolute sales price to 338.00
      And I set the tax class to "MwSt 7.6%"
      Then the product price should be 338.00
      And the rounded price should be 338.00
      And the absolute margin should be roughly 17.3963940520446
      And the taxes should be roughly 23.8736059479554
      
      
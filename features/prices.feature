Feature: Price calculation on products, orders, invoices

  So that the store gives correct prices to customers
  As a customer
  I want to see correct prices for all products

  Background: A system configuration needs to be here
    Given there is a configuration item named "tax_booker_class_name" with value "TaxBookers::SwissTaxBooker"
    And a tax class named "MwSt 7.6%" with the percentage 7.6%


    Scenario: Show price based on purchase price plus margin calculation and taxes
      Given a product
      When I set the purchase price to 100.0
      And I set the margin percentage to 5.0
      And I set the tax class to "MwSt 7.6%"
      Then the taxed product price should be 112.98
      And the taxed rounded price should be 113.0
      And the absolute margin should be 5.0
      And the taxes should be 7.98

    Scenario: Show price based on absolutely defined sales price and taxes
      Given a product
      When I set the purchase price to 97.10
      And I set the absolute sales price to 107.60
      And I set the tax class to "MwSt 7.6%"
      Then the taxed product price should be 115.7776
      And the taxed rounded price should be 115.80
      And the absolute margin should be 10.50
      And the taxes should be 8.1776

    Scenario: Show price based on absolutely defined sales price and taxes with rounding down to 0.5
      Given a product
      When I set the purchase price to 100.00
      And I set the absolute sales price to 120.52
      And I set the tax class to "MwSt 7.6%"
      Then the taxed product price should be 129.67952
      And the taxed rounded price should be 129.70
      And the absolute margin should be 20.52
      And the taxes should be roughly 9.15952

    Scenario: Show price based on absolutely defined sales price and taxes with rounding up to 0.5
      Given a product
      When I set the purchase price to 100.00
      And I set the absolute sales price to 120.58
      And I set the tax class to "MwSt 7.6%"
      Then the taxed product price should be 129.74408
      And the taxed rounded price should be 129.75
      And the absolute margin should be 20.58
      And the taxes should be roughly 9.16408

    Scenario: Show price based on absolutely defined sales price and taxes without need for rounding to 0.5
      Given a product
      When I set the purchase price to 100.00
      And I set the absolute sales price to 120.55
      And I set the tax class to "MwSt 7.6%"
      Then the taxed product price should be 129.7118
      And the taxed rounded price should be 129.75
      And the absolute margin should be 20.55
      And the taxes should be roughly 9.1618



    Scenario: Show price based on more complicated absolutely defined sales price and taxes
      Given a product
      When I set the purchase price to 296.73
      And I set the absolute sales price to 338.00
      And I set the tax class to "MwSt 7.6%"
      Then the taxed product price should be 363.688
      And the taxed rounded price should be 363.70
      And the absolute margin should be 41.27
      And the taxes should be roughly 25.688
      
      
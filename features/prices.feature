Feature: Price calculation on products, orders, invoices

  So that the store gives correct prices to customers
  As a customer
  I want to see correct prices for all products

  Background: A system configuration needs to be here
    Given there is a configuration item named "tax_booker_class_name" with value "TaxBookers::SwissTaxBooker"
    And a tax class named "MwSt 8.0%" with the percentage 8.0%
		And there are the following margin ranges:
		|start_price|end_price|margin_percentage|
		|nil        |nil      |0.0              |

    # By default the margin range that exists hits at 0.0%
    Scenario: Show price based on purchase price plus margin calculation and taxes
      Given a product
      When I set the purchase price to 100.0
      And I set the tax class to "MwSt 8.0%"
      Then the taxed product price should be 108.00
      And the taxed rounded price should be 108.00
      And the absolute margin should be 0.0
      And the taxes should be 8.00

    Scenario: Show price based on absolutely defined sales price and taxes
      Given a product
      When I set the purchase price to 97.10
      And I set the absolute sales price to 108.00
      And I set the tax class to "MwSt 8.0%"
      Then the taxed product price should be 116.64
      And the taxed rounded price should be 116.65
      And the absolute margin should be 10.90
      And the taxes should be 8.64

    Scenario: Show price based on absolutely defined sales price and taxes with rounding down to 0.5
      Given a product
      When I set the purchase price to 100.00
      And I set the absolute sales price to 120.52
      And I set the tax class to "MwSt 8.0%"
      Then the taxed product price should be 130.1616
      And the taxed rounded price should be 130.15
      And the absolute margin should be 20.52
      And the taxes should be roughly 9.6416

    Scenario: Show price based on absolutely defined sales price and taxes with rounding up to 0.5
      Given a product
      When I set the purchase price to 100.00
      And I set the absolute sales price to 120.58
      And I set the tax class to "MwSt 8.0%"
      Then the taxed product price should be 130.2264
      And the taxed rounded price should be 130.25
      And the absolute margin should be 20.58
      And the taxes should be roughly 9.6464

    Scenario: Show price based on absolutely defined sales price and taxes without need for rounding to 0.5
      Given a product
      When I set the purchase price to 100.00
      And I set the absolute sales price to 120.55
      And I set the tax class to "MwSt 8.0%"
      Then the taxed product price should be 130.194
      And the taxed rounded price should be 130.20
      And the absolute margin should be 20.55
      And the taxes should be roughly 9.644

    Scenario: Show price based on more complicated absolutely defined sales price and taxes
      Given a product
      When I set the purchase price to 296.73
      And I set the absolute sales price to 338.00
      And I set the tax class to "MwSt 8.0%"
      Then the taxed product price should be 365.04
      And the taxed rounded price should be 365.05
      And the absolute margin should be 41.27
      And the taxes should be roughly 27.04
      
      
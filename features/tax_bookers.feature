Feature: Book taxes on invoices to the right accounts

  Taxes are booked by TaxBooker classes. Each of these
  can have its own behavior. We should verify that each of
  them works as planned.

  Background: An order exists
    Given a tax class named "MwSt 7.6%" with the percentage 7.6%
    And there is a payment method called "Prepay" which does not allow direct shipping and is the default
    And there is a payment method called "Invoice" which allows direct shipping
    And an order with the following products:
    |quantity|name  |weight|direct_shipping|tax_class |supplier  |purchase_price|margin_percentage|
    |       1|Laptop|   0.90|           true|MwSt 7.6%|Alltron AG|           100|              5.0|
    |       4|Fish  |   1.00|           true|MwSt 7.6%|Alltron AG|           100|              5.0|
    |      18|Foo   |   2.00|           true|MwSt 7.6%|Alltron AG|           100|              5.0|
    #                  40.90
    And the order's payment method is "Prepay"
    And there is a shipping rate called "Alltron AG" with the following costs:
    |weight_min|weight_max|price|tax_percentage|
    |         0|      1000|   10|           7.6|
    And there is a configuration item named "tax_booker_class_name" with value "TaxBookers::SwissTaxBooker"


    Scenario: Book Swiss tax on an invoice (test the SwitzerlandTaxBooker)
      
      pending

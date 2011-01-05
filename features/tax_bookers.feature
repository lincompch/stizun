Feature: Book taxes on invoices to the right accounts

  Taxes are booked by TaxBooker classes. Each of these
  can have its own behavior. We should verify that each of
  them works as planned.

  Background: The framework for creating an order and invoice exists
    Given a tax class named "MwSt 8.0%" with the percentage 8.0%
    And there is a payment method called "Prepay" which is the default
    And there is a payment method called "Invoice"
    And there is a shipping rate called "Alltron AG" with the following costs:
    |weight_min|weight_max|price|tax_percentage|
    |         0|      1000|   10|           8.0|
    |      1001|      2000|   20|           8.0|
    And there are the following suppliers:
    |name|shipping_rate_name|
    |Alltron AG|Alltron AG|
    And the following accounts exist:
    |name  |type|parent|
    |Assets|Account::ASSETS|none|
    |Liabilities|Account::LIABILITIES|none|
    |Income|Account::INCOME|none|
    |Expense|Account::EXPENSE|none|
    |Bank|inherited|Assets|
    |Accounts Receivable|inherited|Assets|
    |Accounts Payable|inherited|Liabilities|
    |Product Sales|inherited|Income|
    |Marketing Expense|inherited|Expense|
    |Product Stock|inherited|Assets|
    And the sales income account is configured
    And the accounts receivable account is configured

    Scenario: Book really trivial Swiss tax on an invoice
      pending

    Scenario: Book Swiss tax on an invoice (more thoroughly test the SwitzerlandTaxBooker)
      Given there is a configuration item named "tax_booker_class_name" with value "TaxBookers::SwitzerlandTaxBooker"
      And an order with the following products:
      |quantity|name  |weight|direct_shipping|tax_class |supplier  |purchase_price|margin_percentage|
      |       1|Laptop|   0.90|           true|MwSt 8.0%|Alltron AG|           100|              5.0|
      |       4|Fish  |   1.00|           true|MwSt 8.0%|Alltron AG|           100|              5.0|
      |      18|Foo   |   2.00|           true|MwSt 8.0%|Alltron AG|           100|              5.0|
      And the order's payment method is "Prepay"
      And the order's total shipping price should be 442.80
      And the order's total weight should be 40.90
      And the order's shipping taxes should be 32.80
      And the order's taxes should be 193.20
      And the order's products total untaxed price should be 2415.00
      And the order's products total taxed price should be 2608.20
      And the order's rounded taxed price should be 3051.0
      And the order's taxed price should be 3051.0
      When I invoice the order
      # Total includes all products, all taxes, even shipping cost and taxes on shipping
      Then the invoice's taxed price is 3051.0
      And the invoice's shipping taxes should be 32.80
      And the invoice's taxes should be 193.20
      # Normal taxes plus shipping taxes are here, we owe them to the country
      And the balance of account "Kreditor MwSt." is 226.0
      And the balance of the sales income account is 2825.0
      When the invoice is paid



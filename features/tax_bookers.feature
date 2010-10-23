Feature: Book taxes on invoices to the right accounts

  Taxes are booked by TaxBooker classes. Each of these
  can have its own behavior. We should verify that each of
  them works as planned.

  Background: The framework for creating an order and invoice exists
    Given a tax class named "MwSt 7.6%" with the percentage 7.6%
    And there is a payment method called "Prepay" which does not allow direct shipping and is the default
    And there is a payment method called "Invoice" which allows direct shipping  
    And there is a shipping rate called "Alltron AG" with the following costs:
    |weight_min|weight_max|price|tax_percentage|
    |         0|      1000|    1|           7.6|
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

    Scenario: Book really trivial Swiss tax on an invoice
      pending

    Scenario: Book Swiss tax on an invoice (more thoroughly test the SwitzerlandTaxBooker)
      Given there is a configuration item named "tax_booker_class_name" with value "TaxBookers::SwitzerlandTaxBooker"
      And an order with the following products:
      |quantity|name  |weight|direct_shipping|tax_class |supplier  |purchase_price|margin_percentage|
      |       1|Laptop|   0.90|           true|MwSt 7.6%|Alltron AG|           100|              5.0|
      |       4|Fish  |   1.00|           true|MwSt 7.6%|Alltron AG|           100|              5.0|
      |      18|Foo   |   2.00|           true|MwSt 7.6%|Alltron AG|           100|              5.0|
      #                  40.90
      And the order's payment method is "Prepay"
      When I invoice the order
      # Total includes all products, all taxes, even shipping cost and taxes on shipping
      Then the invoice total is 2647.45
      # Includes only the raw taxes we owe to the country
      And the balance of account "Kreditor MwSt." is 186.96
      And the balance of the sales income account is 2460.49



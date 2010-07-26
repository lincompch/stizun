Feature: Accounting system

  Accounts should behave correctly and have proper balances so that no money is lost.

  Background: Accounts exist
    Given the following accounts exist:
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

  Scenario: Sell a product
    When the amount 100.00 is credited to "Accounts Receivable" and debited to "Product Sales"
    Then the balance of account "Accounts Receivable" is 100.00
    And the balance of account "Product Sales" is 100.00
    
  Scenario: Attempt to use a root account for transfers and get an error
    When the amount 99.00 is credited to "Assets" and debited to "Expense"
    Then an exception of type "ArgumentError" is raised
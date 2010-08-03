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
    |Product Stock|inherited|Assets|


  Scenario: Sell a product
    When the amount 100.00 is credited to "Accounts Receivable" and debited to "Product Sales"
    Then the balance of account "Accounts Receivable" is 100.00
    And the balance of account "Product Sales" is 100.00
    
  Scenario: All sorts of positive-sum account transfers
    When the amount 100.00 is credited to "Bank" and debited to "Product Sales"
    And the amount 50.00 is credited to "Marketing Expense" and debited to "Bank"
    And the amount 25.00 is credited to "Accounts Payable" and debited to "Bank"
    And the amount 25.00 is credited to "Product Stock" and debited to "Accounts Payable"
    Then the balance of account "Bank" is 25.00
    And the balance of account "Product Sales" is 100.00
    And the balance of account "Marketing Expense" is 50.00
    And the balance of account "Accounts Payable" is 0.00
    And the balance of account "Product Stock" is 25.00
    
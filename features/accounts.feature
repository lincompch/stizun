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

  Scenario: Transfer from assets to expenses
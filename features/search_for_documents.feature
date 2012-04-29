Feature: Search for documents in the admin section

    Background: Set up some necessary things
      Given a minimimal working system setup

    @javascript
    Scenario: Search for order
      Given an order with a few items
      And an invoice for that order
      When I am logged in as an admin
      And I am in the admin area
      And I search for some text from that invoice 
      Then I see a list of invoices
      And that invoice is part of the list

    @javascript
    Scenario: Search for invoice
      Given an order with a few items
      And an invoice for that order
      When I am logged in as an admin
      And I am in the admin area
      And I search for some text from that invoice 
      Then I see a list of invoices
      And that invoice is part of the list


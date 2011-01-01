Feature: Ordering

  So that a customer can buy something
  They need to be able to check out things and fill in an order form

    Background: Some data to select from
      Given a country called "USAnia" exists
      And ActionMailer is set to test mode

    Scenario: Add to cart
      Given a product named "Fish" in the category "Animals"
      When I view the category "Animals"
      And I add the store's only product to my cart
      Then my cart should contain a product named "Fish"

    Scenario: Add to cart multiple times
      Given a product named "Fish" in the category "Animals"
      When I view the category "Animals"
      And I add the store's only product to my cart 4 times
      Then my cart should contain a product named "Fish" 4 times

    Scenario: Add to cart different items
      Given I have ordered some stuff
      Then my cart should contain some stuff

    Scenario: View checkout
      Given I have ordered some stuff
      When I visit the checkout
      Then I should see an order summary

    Scenario: Complete checkout
      Given I have ordered some stuff
      When I visit the checkout
      And I fill in the following within "#billing_address":
      |Firma          |Some Company|
      |Vorname        |Dude|
      |Nachname       |Someguy|
      |E-Mail-Adresse |dude.someguy@example.com|
      |Strasse        |Such an Ordinary Road 1|
      |PLZ            |8000|
      |Stadt          |Sometown|
      And I select "USAnia" from "Land" within "#billing_address" 
      And I submit my order
      Then I should see "Danke für Ihre Bestellung!"
      And I should receive 1 e-mails
      And the subject of e-mail 1 should be "[Local Shop] Bestätigung Ihrer Bestellung"

    Scenario: Complete checkout with different shipping address
      Given I have ordered some stuff
      When I visit the checkout
      And I fill in the following within "#billing_address":
      |Firma          |Some Company|
      |Vorname        |Dude|
      |Nachname       |Someguy|
      |E-Mail-Adresse |dude.someguy@example.com|
      |Strasse        |Such an Ordinary Road 1|
      |PLZ            |8000|
      |Stadt          |Sometown|
      And I select "USAnia" from "Land" within "#billing_address" 
      And I fill in the following within "#shipping_address":
      |Firma          |Some Other Company|
      |Vorname        |Other Dude|
      |Nachname       |Someotherguy|
      |E-Mail-Adresse |otherdude.someguy@example.com|
      |Strasse        |Such an Exceptional Road 1|
      |PLZ            |7000|
      |Stadt          |Othertown|
      And I select "USAnia" from "Land" within "#shipping_address" 
      And I submit my order
      Then I should see "Danke für Ihre Bestellung!"
      And I should receive 1 e-mails
      And the subject of e-mail 1 should be "[Local Shop] Bestätigung Ihrer Bestellung"

    Scenario: Forget filling in some important fields when ordering

    Scenario: Use saved address when ordering
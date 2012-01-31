Feature: Ordering

  So that a customer can buy something
  They need to be able to check out things and fill in an order form

    Background: Some data to select from
      Given a country called "USAnia" exists
      And there is a default shipping calculator of type ShippingCalculatorBasedOnWeight called "Alltron AG" with the following costs:
      |weight_min|weight_max|price|
      |         0|      1000|   10|
      |      1001|      2000|   20|
      |      2001|      3000|   30|
      |      3001|      4000|   40|
      |      4001|      5000|   50|
      And there are the following suppliers:
      |name|
      |Alltron AG|
      And ActionMailer is set to test mode


    Scenario: Add to cart
      Given the following products exist(table):
      |name|category|supplier|purchase_price|
      |Fish|Animals|Alltron AG|100.0|
      When I view the category "Animals"
      And I add the product "Fish" to my cart 1 times
      Then my cart should contain a product named "Fish"

    Scenario: Add to cart multiple times
      Given the following products exist(table):
      |name|category|supplier|purchase_price|weight|
      |Fish|Animals|Alltron AG|100.0|10.0|
      When I view the category "Animals"
      And I add the product "Fish" to my cart 4 times
      Then my cart should contain a product named "Fish" 4 times

    Scenario: See correct totals on checkout page for one single product
      Given the following products exist(table):
      |name|category|supplier|purchase_price|weight|
      |Fish|Animals|Alltron AG|100.0|10.0|
      When I view the category "Animals"
      And I add the product "Fish" to my cart 1 times
      And I visit the checkout
      Then I should see an order summary
      And the order summary should contain a total excluding VAT of 105.0
      And the order summary should contain a VAT of 8.40
      And the order summary should contain a product total including VAT of 113.40
      And the order summary should contain shipping cost including VAT of 108.0
      And the order summary should contain a grand total of 221.40

    Scenario: View checkout
      Given the following products exist(table):
      |name|category|supplier|purchase_price|weight|
      |Fish|Animals|Alltron AG|100.0|10.0|
      |Terminator T-1000|Cyborgs|Alltron AG|100.0|10.0|
      When I view the category "Animals"
      And I add the product "Fish" to my cart 4 times
      And I view the category "Cyborgs"
      And I add the product "Terminator T-1000" to my cart 2 times
      And I visit the checkout
      Then I should see an order summary

    Scenario: Complete checkout
      Given the following products exist(table):
      |name|category|supplier|purchase_price|
      |Fish|Animals|Alltron AG|100.0|
      |Terminator T-1000|Cyborgs|Alltron AG|100.0|
      When I view the category "Animals"
      And I add the product "Fish" to my cart 4 times
      And I view the category "Cyborgs"
      And I add the product "Terminator T-1000" to my cart 2 times
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
      And I check "order_terms_of_service"
      And I submit my order
      Then I should see "Danke für Ihre Bestellung!"
      And I should receive 2 e-mails
      And the subject of e-mail 2 should be "[Local Shop] Bestätigung Ihrer Bestellung"
      And the subject of e-mail 1 should be "[Local Shop] Elektronische Rechnung"

    Scenario: Complete checkout with different shipping address
      Given the following products exist(table):
      |name|category|supplier|purchase_price|
      |Fish|Animals|Alltron AG|100.0|
      |Terminator T-1000|Cyborgs|Alltron AG|100.0|
      When I view the category "Animals"
      And I add the product "Fish" to my cart 4 times
      And I view the category "Cyborgs"
      And I add the product "Terminator T-1000" to my cart 2 times
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
      And I check "order_terms_of_service"
      And I submit my order
      Then I should see "Danke für Ihre Bestellung!"
      And I should receive 2 e-mails
      And the subject of e-mail 2 should be "[Local Shop] Bestätigung Ihrer Bestellung"
      And the subject of e-mail 1 should be "[Local Shop] Elektronische Rechnung"


    Scenario: Forget filling in some important fields when ordering

    Scenario: Use saved address when ordering

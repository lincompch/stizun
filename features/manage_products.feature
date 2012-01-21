Feature: Create and manage products

    Background: Set up some necessary things
      Given the Sphinx indexes are updated
      And a category named "Notebooks" exists
      And there is a configuration item named "currency" with value "CHF"
      And there is a user with e-mail address "admin@something.com" and password "foobar"
      And a tax class named "MwSt 8.0%" with the percentage 8.0%
      And the user group "Admins" exists
      And the user group "Admins" has admin permissions
      And the user is member of the group "Admins"
      And I log in with e-mail address "admin@something.com" and password "foobar"
      And there is a default shipping shipping calculator of type ShippingCalculatorBasedOnWeight called "Alltron AG" with the following costs:
      |weight_min|weight_max|price|
      |         0|      1000|   10|
      |      1001|      2000|   20|
      |      2001|      3000|   30|
      |      3001|      4000|   40| 
      |      4001|      5000|   50|
      And there are the following suppliers:
      |name|
      |Alltron AG|
      And there are the following margin ranges:
			|start_price|end_price|margin_percentage|
			|nil|nil|0.0              |
			|0|100000|5.0              |
      And there is a payment method called "Prepay" which is the default
      Given the Sphinx indexes are updated

    @javascript
    Scenario: Create product
      Given a category named "Notebooks" exists
      When I create a product called "Lenovo T400"
      And I wait for a fancybox to appear
      And I fill in "Some laptop" in the CKEditor instance "product_description"
      And I fill in the purchase price 100.0
      And I fill in the weight 5.0
      And I select the supplier "Alltron AG"
      And I select the tax class "MwSt 8.0%"
      And I assign the product to the category "Notebooks"
      And I click the create button
      Then I should see "Product created." in the fancybox
      And there should be a product called "Lenovo T400"
      And the category "Notebooks" should contain a product named "Lenovo T400"

    @javascript
    Scenario: Forget assigning a tax class when creating a product
      Given a category named "Notebooks" exists
      When I create a product called "Lenovo T500"
      And I wait for a fancybox to appear
      And I fill in "Some other laptop" in the CKEditor instance "product_description"
      And I fill in the purchase price 100.0
      And I fill in the weight 5.0
      And I select the supplier "Alltron AG"
      And I click the create button
      Then I should see an error message inside the fancybox
      And there should not be a product called "Lenovo T500"

    @javascript
    Scenario: Edit multiple products category
      Given a category: "computers" exists with name: "computers"
      Given a product: "pc" exists with name: "pc"
      And a product: "laptop" exists with name: "laptop"
      And I am on the admin products page
      Then I should see "Not editing multiple products"
      And I check product: "pc"'s first checkbox
      Then I should see "Editing multiple products"
      And I check product: "laptop"'s first checkbox
      And I follow "Edit" within "#batch_actions"
      And I should see "pc"
      And I should see "laptop"
      Then I select "computers" from "product_category_ids_"
      And I press "Submit"
      Then category: "computers" should contain product: "pc"
      And category: "computers" should contain product: "laptop"


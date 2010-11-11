Feature: Importing products and supply items from Alltron CSV files

  Scenario: Importing list of 500 base products
    When I import the file "500_products_utf8.csv"
    Then there are 500 products in the database
    And the following supply items exist:
    |product_code|weight|price|stock|
    |        1289|  0.54|40.38|    4|
    |        2313|  0.06|24.49|    3|
    |        3188|  0.28|36.90|   55|    
    |        5509|  0.08|19.80|  545|    
    |        6591|  0.07|20.91|    2|    

   
  Scenario: Importing list with 5 changes
    When I import the file "500_products_with_5_changes.csv"
    
  
  Scenario: Importing list with 15 missing products
    When I import the file "485_products_utf8.csv"

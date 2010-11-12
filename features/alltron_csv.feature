Feature: Importing products and supply items from Alltron CSV files

  Background: No supply items exist
    When I destroy all supply items
    Then there are 0 supply items in the database
    

  Scenario: Importing list of 500 base products
    When I import the file "features/data/500_products.csv"
    Then there are 500 supply items in the database
    And the following supply items exist:
    |product_code|weight|price|stock|
    |        1289|  0.54|40.38|    4|
    |        2313|  0.06|24.49|    3|
    |        3188|  0.28|36.90|   55|    
    |        5509|  0.08|19.80|  545|    
    |        6591|  0.07|20.91|    2|    

   
  Scenario: Importing list with 5 changes
    When I import the file "features/data/500_products_with_5_changes.csv"
    Then there are 500 supply items in the database
    And the following supply items exist:
    |product_code|weight|price|stock|
    |        1289|  0.54|40.00|    4|
    |        2313|  0.06|24.49|  100|
    |        3188|  0.50|36.90|   55|    
    |        5509|  0.50|25.00|  545|    
    |        6591|  2.00|40.00|   18|        
  
  Scenario: Importing list with 15 missing products
    When I import the file "features/data/485_products_utf8.csv"
    Then there are 485 supply items in the database

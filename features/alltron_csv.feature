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
    And the following history entries exist:
    |text               |type_const|
    |Supply item added during sync: 2313 Tinte Canon BJC 2000/4x00/5000 Nachfüllpatrone farbig|History::SUPPLY_ITEM_CHANGE|

   
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
    When I import the file "features/data/500_products.csv"
    And I import the file "features/data/485_products_utf8.csv"
    Then there are 485 supply items in the database
    And the following supply items do not exist:
    |product_code|
    |1227|
    |1510|
    |1841|
    |1847|
    |2180|
    |2193|
    |2353|
    |2379|
    |3220|
    |4264|
    |5048|
    |5768|
    |5862|
    |5863|
    |8209|
    And the following history entries exist:
    |text                                       |type_const                 |
    |Deleted Supply Item with supplier code 1227|History::SUPPLY_ITEM_CHANGE|
    |Deleted Supply Item with supplier code 1510|History::SUPPLY_ITEM_CHANGE|
    |Deleted Supply Item with supplier code 2180|History::SUPPLY_ITEM_CHANGE|
    |Deleted Supply Item with supplier code 3220|History::SUPPLY_ITEM_CHANGE|
    |Deleted Supply Item with supplier code 5862|History::SUPPLY_ITEM_CHANGE|
    |Deleted Supply Item with supplier code 8209|History::SUPPLY_ITEM_CHANGE|    
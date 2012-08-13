# Language: de

Funktionalität: Switch to available automatisieren

  Grundlage: Supplier und deren Supply Items existieren 
	Angenommen es gibt folgende Supply Items:
	|name                |manufacturer_product_code|supplier_product_code|supplier  |purchase_price|
	|Disktation DS110j_1w|123                      |1                    |Alltron AG|100.0|
	|Disktation DS110j_1w|123                      |1                    |Ingram Micro GmbH|200.0|
	|Disktation DS110j_1w|123                      |1                    |jET Schweiz IT AG|300.0|
	Und ein Produkt "Disktation DS110j_1w" mit Manufacturer Product Code "123" und Supplier Product Code "1"
	Und das Produkt ist verbunden mit dem Supply Item mit Supplier Product Code "1"
	
  Szenario: Verhindern eines ausverkauften Supply Items, wenn dieses noch bei mindestens einem Händler an Lager ist
	Wenn das Supply Item vom Supplier "Alltron AG" nicht mehr verfügbar ist
	Dann ist das Produkt verbunden mit dem Supply Item von "Ingram Micro GmbH" oder "jET Schweiz IT AG"
	Wenn das Supply Item vom Supplier "Ingram Micro GmbH" nicht mehr verfügbar ist
	Dann ist das Produkt verbunden mit dem Supply Item von "jET Schweiz IT AG"
	Wenn das Supply Item vom Supplier "jET Schweiz IT AG" nicht mehr verfügbar ist
	Dann ist das Produkt nicht verfügbar 

  Szenario: Entscheiden, zu welchem Supply Item gewechselt wird, wenn mehrere verfügbar sind
	# TODO: Beschreiben, dass nach Preis sortiert und immer das günstigste genommen wird.
	# TODO: Beschreiben, wie bei einem unentschieden zwischen zwei Preisen umgegangen wird.
	#

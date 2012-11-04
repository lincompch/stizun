# language: de

Funktionalität: Switch to available automatisieren

  Grundlage: Supplier und deren Supply Items existieren 
    Angenommen es gibt folgende Supply Items:
    |name                |manufacturer_product_code|ean_code|supplier_product_code|supplier         |price|stock|
    |Disktation DS110j_1w|123                      |XYZ12   |1                    |Alltron AG       |100.0|10|
    |Disktation DS110j_1w|123                      |XYZ12   |2                    |Ingram Micro GmbH|200.0|10|
    |Disktation DS110j_1w|123                      |XYZ12   |3                    |jET Schweiz IT AG|300.0|10|
    |Disktation DS110j_1w|                         |XYZ12   |4                    |jET Schweiz IT AG|300.0|10|
    Und ein Produkt "Disktation DS110j_1w" mit Manufacturer Product Code "123" und Supplier Product Code "1"
    Und das Produkt ist verbunden mit dem Supply Item mit Supplier Product Code "1"
    
  Szenario: Verhindern eines ausverkauften Supply Items, wenn dieses noch bei mindestens einem Händler an Lager ist
    Angenommen alle Supply Items sind verfügbar
    Dann ist das Produkt verbunden mit dem Supply Item "1" von "Alltron AG"
    Wenn das Supply Item "1" vom Supplier "Alltron AG" nicht mehr verfügbar ist
    Dann ist das Produkt verbunden mit dem Supply Item "2" von "Ingram Micro GmbH"
    Wenn das Supply Item "2" vom Supplier "Ingram Micro GmbH" nicht mehr verfügbar ist
    Dann ist das Produkt verbunden mit dem Supply Item "3" von "jET Schweiz IT AG"
    Wenn das Supply Item "3" vom Supplier "jET Schweiz IT AG" nicht mehr verfügbar ist
    Dann ist das Produkt nicht verfügbar 
    
  Szenario: Supply Items, die Stückzahl 0 oder weniger beim Supplier haben, werden nicht berücksichtigt 
    Angenommen alle Supply Items sind verfügbar
    Dann ist das Produkt verbunden mit dem Supply Item "1" von "Alltron AG"
    Wenn das Supply Item "1" vom Supplier "Alltron AG" nicht mehr verfügbar ist
    Und der Supplier "Ingram Micro GmbH" 0 Stück vom Supply Item "2" an Lager hat
    Dann ist das Produkt verbunden mit dem Supply Item "3" von "jET Schweiz IT AG"
    Wenn das Supply Item "3" vom Supplier "jET Schweiz IT AG" nicht mehr verfügbar ist
    Dann ist das Produkt nicht verfügbar 

  Szenario: Supply Items, die keinen Manufacturer Product Code haben, werden in all diesen vergleichen übersprungen
    Angenommen alle Supply Items sind verfügbar
    Dann erscheint das Supply Item "4" vom Supplier "jET Schweiz IT AG" nicht als mögliche Alternative für automatisches Switch-To

  Szenario: Geht ein aktuell dem Produkt zugewiesenes Supply Item auf 0, sucht das System die nächstgünstigste Alternative bei anderen Suppliern
    Angenommen alle Supply Items sind verfügbar
    Dann ist das Produkt verbunden mit dem Supply Item "1" von "Alltron AG"
    Wenn der Supplier "Alltron AG" 0 Stück vom Supply Item "1" an Lager hat
    Dann ist das Produkt verbunden mit dem Supply Item "2" von "Ingram Micro GmbH"

  Szenario: Entscheiden, zu welchem Supply Item gewechselt wird, wenn mehrere verfügbar sind
    Angenommen das Produkt ist verbunden mit dem Supply Item mit Supplier Product Code "3"
    Und es günstigere Supply Items für das Produkt gibt 
    Und dessen Supplier 2 Stück des günstigsten Supply Items an Lager hat
    Dann ist dieses Supply Item der beste Kandidat für einen automatischen Wechsel
    Wenn der Supplier 0 Stück dieses Supply Items an Lager hat
    Dann ist dieses Supply Item nicht der beste Kandidat für einen automatischen Wechsel

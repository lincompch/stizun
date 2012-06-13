

JobConfigurationTemplate.create(:job_class => 'AlltronUtil',
                                :job_method => 'import_supply_items',
                                :job_arguments => '"lib/AL_Artikeldaten.txt"')

JobConfigurationTemplate.create(:job_class => 'AlltronUtil',
                                :job_method => 'update_supply_items',
                                :job_arguments => '"lib/AL_Artikeldaten.txt"')

JobConfigurationTemplate.create(:job_class => 'IngramUtil',
                                :job_method => 'import_supply_items',
                                :job_arguments => '"lib/620030.txt"')

JobConfigurationTemplate.create(:job_class => 'IngramUtil',
                                :job_method => 'update_supply_items',
                                :job_arguments => '"lib/620030.txt"')

JobConfigurationTemplate.create(:job_class => 'JetUtil',
                                :job_method => 'import_supply_items',
                                :job_arguments => '"lib/jETArtikelliste.csv"')

JobConfigurationTemplate.create(:job_class => 'JetUtil',
                                :job_method => 'update_supply_items',
                                :job_arguments => '"lib/jETArtikelliste.csv"')

JobConfigurationTemplate.create(:job_class => 'AlltronUtil',
                                :job_method => 'import_supply_items',
                                :job_arguments => '"lib/AL_Artikeldaten.txt"')

JobConfigurationTemplate.create(:job_class => 'Product',
                                :job_method => 'export_available_to_csv')

JobConfigurationTemplate.create(:job_class => 'Product',
                                :job_method => 'update_price_and_stock')


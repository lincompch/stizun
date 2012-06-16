

JobConfigurationTemplate.create(:job_class => 'JobExecutor',
                                :job_method => 'import_supply_items',
                                :job_arguments => 'Alltron AG,lib/AL_Artikeldaten.txt')

JobConfigurationTemplate.create(:job_class => 'JobExecutor',
                                :job_method => 'update_supply_items',
                                :job_arguments => 'Alltron AG,lib/AL_Artikeldaten.txt')

JobConfigurationTemplate.create(:job_class => 'JobExecutor',
                                :job_method => 'import_supply_items',
                                :job_arguments => 'Ingram Micro GmbH,lib/620030.txt')

JobConfigurationTemplate.create(:job_class => 'JobExecutor',
                                :job_method => 'update_supply_items',
                                :job_arguments => 'Ingram Micro GmbH,lib/620030.txt')

JobConfigurationTemplate.create(:job_class => 'JobExecutor',
                                :job_method => 'import_supply_items',
                                :job_arguments => 'jET Schweiz IT AG,lib/jETArtikelliste.csv')

JobConfigurationTemplate.create(:job_class => 'JobExecutor',
                                :job_method => 'update_supply_items',
                                :job_arguments => 'jET Schweiz IT AG,lib/jETArtikelliste.csv')

JobConfigurationTemplate.create(:job_class => 'JobExecutor',
                                :job_method => 'export_product_to_csv')

JobConfigurationTemplate.create(:job_class => 'JobExecutor',
                                :job_method => 'update_price_and_stock')


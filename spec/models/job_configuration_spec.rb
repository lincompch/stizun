require 'spec_helper'

describe JobConfiguration do

    before(:each) do
      JobConfigurationTemplate.create(:job_class => 'Foo', :job_method => 'bar')
    end

    it "should affect today based on its repetition" do
      daily = JobRepetition.create(:month => nil, :dom => nil, :dow => nil, :minute => 0, :hour => 11)
      wednesdays = JobRepetition.create(:month => nil, :dom => nil, :dow => 3, :minute => 0, :hour => 11)
      july_1 = JobRepetition.create(:month => 7, :dom => 1, :dow => nil, :minute => 0, :hour => 11)

      daily_configuration = JobConfiguration.create(:job_configuration_template => JobConfigurationTemplate.first, 
                                                    :job_repetition => daily)

      wednesday_configuration = JobConfiguration.create(:job_configuration_template => JobConfigurationTemplate.first, 
                                                        :job_repetition => wednesdays)

      july_1_configuration = JobConfiguration.create(:job_configuration_template => JobConfigurationTemplate.first, 
                                                     :job_repetition => july_1)

      # Every day
      JobConfiguration.affecting_day(Date.tomorrow).include?(daily_configuration).should == true
      JobConfiguration.affecting_day(Date.today + 5.days).include?(daily_configuration).should == true
      JobConfiguration.affecting_day(Date.today + 100.days).include?(daily_configuration).should == true

      # Wednesdays
      JobConfiguration.affecting_day(Date.parse("2012-07-04")).include?(wednesday_configuration).should == true
      JobConfiguration.affecting_day(Date.parse("2012-07-01")).include?(wednesday_configuration).should == false
      JobConfiguration.affecting_day(Date.parse("2012-07-02")).include?(wednesday_configuration).should == false
      JobConfiguration.affecting_day(Date.parse("2012-07-03")).include?(wednesday_configuration).should == false            
      JobConfiguration.affecting_day(Date.parse("2012-07-05")).include?(wednesday_configuration).should == false            
      JobConfiguration.affecting_day(Date.parse("2012-07-06")).include?(wednesday_configuration).should == false            
      JobConfiguration.affecting_day(Date.parse("2012-07-07")).include?(wednesday_configuration).should == false            
      JobConfiguration.affecting_day(Date.parse("2012-07-08")).include?(wednesday_configuration).should == false            
      JobConfiguration.affecting_day(Date.parse("2012-07-09")).include?(wednesday_configuration).should == false            
      JobConfiguration.affecting_day(Date.parse("2012-07-10")).include?(wednesday_configuration).should == false
      JobConfiguration.affecting_day(Date.parse("2012-07-11")).include?(wednesday_configuration).should == true

      # July 1st
      JobConfiguration.affecting_day(Date.parse("2012-07-01")).include?(july_1_configuration).should == true
      JobConfiguration.affecting_day(Date.parse("2013-07-01")).include?(july_1_configuration).should == true
      JobConfiguration.affecting_day(Date.parse("2013-07-02")).include?(july_1_configuration).should == false


    end

    it "should affect today based on its absolute run_at time" do
      today_configuration = JobConfiguration.create(:job_configuration_template => JobConfigurationTemplate.first, 
                                                    :run_at => DateTime.now + 5.hours)

      JobConfiguration.affecting_day(Date.today + 1.day).include?(today_configuration).should == false
      JobConfiguration.affecting_day(Date.today - 1.day).include?(today_configuration).should == false
      JobConfiguration.affecting_day(Date.today).include?(today_configuration).should == true

    end



end
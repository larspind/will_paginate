require 'spec_helper'

begin
  require 'will_paginate/data_mapper'
  require File.expand_path('../data_mapper_test_connector', __FILE__)
rescue LoadError => error
  warn "Error running DataMapper specs: #{error.message}"
  datamapper_loaded = false
else
  datamapper_loaded = true
end

describe WillPaginate::DataMapper do

  it "has per_page" do
    Animal.per_page.should == 30
    begin
      Animal.per_page = 10
      Animal.per_page.should == 10

      subclass = Class.new(Animal)
      subclass.per_page.should == 10
    ensure
      Animal.per_page = 30
    end
  end

  it "doesn't make normal collections appear paginated" do
    Animal.all.should_not be_paginated
  end

  it "paginates to first page by default" do
    animals = Animal.paginate(:page => nil)

    animals.should be_paginated
    animals.current_page.should == 1
    animals.per_page.should == 30
    animals.offset.should == 0
    animals.total_entries.should == 3
    animals.total_pages.should == 1
  end

  it "paginates to first page, explicit limit" do
    animals = Animal.paginate(:page => 1, :per_page => 2)

    animals.current_page.should == 1
    animals.per_page.should == 2
    animals.total_entries.should == 3
    animals.total_pages.should == 2
    animals.map {|a| a.name }.should == %w[ Dog Cat ]
  end

  it "paginates to second page" do
    animals = Animal.paginate(:page => 2, :per_page => 2)

    animals.current_page.should == 2
    animals.offset.should == 2
    animals.map {|a| a.name }.should == %w[ Lion ]
  end

  it "paginates a collection" do
    friends = Animal.all(:notes.like => '%friend%')
    friends.paginate(:page => 1).per_page.should == 30
    friends.paginate(:page => 1, :per_page => 1).total_entries.should == 2
  end

  it "paginates a limited collection" do
    animals = Animal.all(:limit => 2).paginate(:page => 1)
    animals.per_page.should == 2
  end

  it "has page() method" do
    Animal.page(2).per_page.should == 30
    Animal.page(2).offset.should == 30
    Animal.page(2).current_page.should == 2
    Animal.all(:limit => 2).page(2).per_page.should == 2
  end

  it "has total_pages at 1 for empty collections" do
    Animal.all(:conditions => ['1=2']).page(1).total_pages.should == 1
  end

end if datamapper_loaded

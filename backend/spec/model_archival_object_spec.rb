require 'spec_helper'

describe 'ArchivalObject model' do

  it "allows archival objects to be created" do
    ao = ArchivalObject.create_from_json(
                                          build(
                                                :json_archival_object,
                                                :title => 'A new archival object'
                                                ),
                                          :repo_id => $repo_id)

    ArchivalObject[ao[:id]].title.should eq('A new archival object')
  end


  it "allows multiple archival objects to be created without conflicts" do
    create_list(:json_archival_object, 5)
  end


  it "allow archival objects to be created with an extent" do
    
    opts = {:extents => [{
      "portion" => "whole",
      "number" => "5 or so",
      "extent_type" => generate(:extent_type),
    }]}
    
    ao = ArchivalObject.create_from_json(
                                          build(:json_archival_object, opts),
                                          :repo_id => $repo_id)
    ArchivalObject[ao[:id]].extent.length.should eq(1)
    ArchivalObject[ao[:id]].extent[0].extent_type.should eq(opts[:extents][0]['extent_type'])
  end


  it "allows archival objects to be created with a date" do
    
    opts = {:dates => [{
         "date_type" => "single",
         "label" => "creation",
         "begin" => generate(:yyyy_mm_dd),
      }]}
    
    ao = ArchivalObject.create_from_json(
                                          build(:json_archival_object, opts),
                                          :repo_id => $repo_id)

    ArchivalObject[ao[:id]].date.length.should eq(1)
    ArchivalObject[ao[:id]].date[0].begin.should eq(opts[:dates][0]['begin'])
  end


  it "allows archival objects to be created with an instance" do
    
    opts = {:instances => [{
         "instance_type" => generate(:instance_type),
         "container" => build(:json_container)
       }]}
    
       ao = ArchivalObject.create_from_json(
                                             build(:json_archival_object, opts),
                                             :repo_id => $repo_id)

    ArchivalObject[ao[:id]].instance.length.should eq(1)
    ArchivalObject[ao[:id]].instance[0].instance_type.should eq(opts[:instances][0]['instance_type'])
    ArchivalObject[ao[:id]].instance[0].container.first.type_1.should eq(opts[:instances][0]['container']['type_1'])
  end


  it "will generate a ref_id if non is provided" do
    ao = ArchivalObject.create_from_json(build(:json_archival_object),
                                         :repo_id => $repo_id)

    ArchivalObject[ao[:id]].ref_id.should_not be_nil
  end


  it "will generate a label if requested" do
    opts = {
      :title => "", 
      :dates => [{
                   "date_type" => "single",
                   "label" => "creation",
                   "begin" => generate(:yyyy_mm_dd),
                 }]
    }

    ao = ArchivalObject.create_from_json(build(:json_archival_object, opts),
                                         :repo_id => $repo_id)

    ArchivalObject[ao[:id]].label.should_not be_nil
  end


  it "throws an error if 'level' is 'otherlevel' and 'other level' isn't provided, but only in strict mode" do

    opts = {:level => "otherlevel", :other_level => nil}

    expect { ArchivalObject.create_from_json(
                                build(:json_archival_object, opts),
                                :repo_id => $repo_id)
    }.to raise_error(JSONModel::ValidationException)
    
    JSONModel::strict_mode(false)
    
    expect { ArchivalObject.create_from_json(
                                build(:json_archival_object, opts),
                                :repo_id => $repo_id)
    }.to_not raise_error
    
    JSONModel::strict_mode(true)
    
  end


  it "enforces ref_id uniqueness only within a resource" do
    res1 = create(:json_resource)
    res2 = create(:json_resource)

    create(:json_archival_object, {:ref_id => "the_same", :resource => {:ref => res1.uri}})
    create(:json_archival_object, {:ref_id => "the_same", :resource => nil})

    expect {
      create(:json_archival_object, {:ref_id => "the_same", :resource => {:ref => res1.uri}})
    }.to raise_error(JSONModel::ValidationException)

    expect {
      create(:json_archival_object, {:ref_id => "the_same", :resource => nil})
    }.to_not raise_error
  end


  it "can create an AO with a position set" do
    res1 = create(:json_resource)

    expect {
      create(:json_archival_object,
             {
               :ref_id => "the_same",
               :resource => {:ref => res1.uri},
               :position => 0
             })
    }.to_not raise_error
  end

  it "auto generates a 'label' based on the title (when no date)" do
    title = "Just a title"

    ao = ArchivalObject.create_from_json(
          build(:json_archival_object, {
            :title => title
          }),
          :repo_id => $repo_id)

    ArchivalObject[ao[:id]].label.should eq(title)
  end

  it "auto generates a 'label' based on the date (when no title)" do
    # if an expression that will display
    date = build(:json_date)
    ao = ArchivalObject.create_from_json(
      build(:json_archival_object, {
        :title => nil,
        :dates => [date]
      }),
      :repo_id => $repo_id)

    ArchivalObject[ao[:id]].label.should eq(date['expression'])

    # try with begin and end
    date = build(:json_date, :expression => nil)
    ao = ArchivalObject.create_from_json(
      build(:json_archival_object, {
        :title => nil,
        :dates => [date]
      }),
      :repo_id => $repo_id)

    ArchivalObject[ao[:id]].label.should eq("#{date['begin']} - #{date['end']}")
  end

  it "auto generates a 'label' based on the date and title when both are present" do
    title = "Just a title"
    date = build(:json_date)

    ao = ArchivalObject.create_from_json(
      build(:json_archival_object, {
        :title => title,
        :dates => [date]
      }),
      :repo_id => $repo_id)

    ArchivalObject[ao[:id]].label.should eq("#{title}, #{date['expression']}")
  end

end

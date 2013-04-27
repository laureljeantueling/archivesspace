require 'spec_helper'

describe 'Collection Management controller' do

  it "lets you list all collection management records" do
    JSONModel(:accession).from_hash("id_0" => "1234",
                                    "title" => "The accession title",
                                    "content_description" => "The accession description",
                                    "condition_description" => "The condition description",
                                    "accession_date" => "2012-05-03",
                                    "collection_management" => { "cataloging_note" => "Just a note" }).save

    create(:json_resource, { :collection_management => {'cataloging_note' => "A note on a resource" } })

    JSONModel(:collection_management).all(:page => 1)['results'].count.should eq(2)
  end

end

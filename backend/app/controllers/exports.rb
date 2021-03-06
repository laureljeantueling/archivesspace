class ArchivesSpaceService < Sinatra::Base
  
  include ExportHelpers

  Endpoint.get('/repositories/:repo_id/digital_objects/dublin_core/:digital_object_id.xml')
    .description("Get a Dublin Core representation of a Digital Object ")
    .params(["digital_object_id", Integer, "The ID of the digital object to render"],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "(:digital_object)"]) \
  do
    dc = generate_dc(params[:digital_object_id])
    
    xml_response(dc)
  end


  Endpoint.get('/repositories/:repo_id/digital_objects/mets/:digital_object_id.xml')
    .description("Get a METS representation of a Digital Object ")
    .params(["digital_object_id", Integer, "The ID of the digital object to render"],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "(:digital_object)"]) \
  do
    mets = generate_mets(params[:digital_object_id])
    
    xml_response(mets)
  end

  Endpoint.get('/repositories/:repo_id/digital_objects/mods/:digital_object_id.xml')
    .description("Get a MODS representation of a Digital Object ")
    .params(["digital_object_id", Integer, "The ID of the digital object to render"],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "(:digital_object)"]) \
  do
    mods = generate_mods(params[:digital_object_id])
    
    xml_response(mods)    
  end
  
  Endpoint.get('/repositories/:repo_id/resources/marc21/:resource_id.xml')
    .description("Get a MARC 21 representation of a Resource")
    .params(["resource_id", Integer, "The ID of the resource to retrieve"],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "(:resource)"]) \
  do
    marc = generate_marc(params[:resource_id])
    
    xml_response(marc)    
  end
  

  Endpoint.get('/repositories/:repo_id/resource_descriptions/:resource_id.xml')
    .description("Get an EAD representation of a Resource")
    .params(["resource_id", Integer, "The ID of the resource to retrieve"],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "(:resource)"]) \
  do
    ead = generate_ead(params[:resource_id])
    
    xml_response(ead)
  end
  
  Endpoint.get('/repositories/:repo_id/resource_labels/:resource_id.tsv')
    .description("Get a tsv list of printable labels for a Resource")
    .params(["resource_id", Integer, "The ID of the resource to retrieve"],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "(:resource)"]) \
  do
    tsv = generate_labels(params[:resource_id])
    
    tsv_response(tsv)
  end
  
  Endpoint.get('/archival_contexts/people/:agent_id.xml')
    .description("Get an EAC-CPF representation of an Agent")
    .params(["agent_id", Integer, "The ID of the Agent to retrieve"])
    .permissions([])
    .returns([200, "(:agent)"]) \
  do
    eac = generate_eac(params[:agent_id], 'agent_person')
    
    xml_response(eac)
  end
  
  Endpoint.get('/archival_contexts/corporate_entities/:agent_id.xml')
    .description("Get an EAC-CPF representation of a Corporate Entity")
    .params(["agent_id", Integer, "The ID of the Agent to retrieve"])
    .permissions([])
    .returns([200, "(:agent)"]) \
  do
    eac = generate_eac(params[:agent_id], 'agent_corporate_entity')
    
    xml_response(eac)
  end
  
  Endpoint.get('/archival_contexts/families/:agent_id.xml')
    .description("Get an EAC-CPF representation of a Family")
    .params(["agent_id", Integer, "The ID of the Agent to retrieve"])
    .permissions([])
    .returns([200, "(:agent)"]) \
  do
    eac = generate_eac(params[:agent_id], 'agent_family')
    
    xml_response(eac)
  end
  
  Endpoint.get('/archival_contexts/softwares/:agent_id.xml')
    .description("Get an EAC-CPF representation of a Software agent")
    .params(["agent_id", Integer, "The ID of the Agent to retrieve"])
    .permissions([])
    .returns([200, "(:agent)"]) \
  do
    eac = generate_eac(params[:agent_id], 'agent_software')
    
    xml_response(eac)
  end
  
  
end

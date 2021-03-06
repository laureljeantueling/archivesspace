class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/agents/corporate_entities')
    .description("Create a corporate entity agent")
    .params(["agent", JSONModel(:agent_corporate_entity), "The corporate entity to create", :body => true])
    .permissions([:update_agent_record])
    .returns([200, :created],
             [400, :error]) \
  do
    handle_create(AgentCorporateEntity, :agent)
  end


  Endpoint.get('/agents/corporate_entities')
    .description("List all corporate entity agents")
    .params()
    .paginated(true)
    .permissions([])
    .returns([200, "[(:agent_corporate_entity)]"]) \
  do
    handle_listing(AgentCorporateEntity, params)
  end


  Endpoint.post('/agents/corporate_entities/:agent_id')
    .description("Update a corporate entity agent")
    .params(["agent_id", Integer, "The ID of the agent to update"],
            ["agent", JSONModel(:agent_corporate_entity), "The corporate entity to create", :body => true])
    .permissions([:update_agent_record])
    .returns([200, :updated],
             [400, :error]) \
  do
    handle_update(AgentCorporateEntity, :agent_id, :agent)
  end


  Endpoint.get('/agents/corporate_entities/:id')
    .description("Get a corporate entity by ID")
    .params(["id", Integer, "ID of the corporate entity agent"],
            ["resolve", [String], "A list of references to resolve and embed in the response",
             :optional => true])
    .permissions([])
    .returns([200, "(:agent)"],
             [404, '{"error":"Agent not found"}']) \
  do
    json_response(resolve_references(AgentCorporateEntity.to_jsonmodel(AgentCorporateEntity.get_or_die(params[:id])),
                                     params[:resolve]))
  end

  Endpoint.delete('/agents/corporate_entities/:id')
    .description("Delete a corporate entity agent")
    .params(["id", Integer, "ID of the corporate entity agent"])
    .permissions([:delete_agent_record])
    .returns([200, :deleted]) \
  do
    handle_delete(AgentCorporateEntity, params[:id])
  end

end

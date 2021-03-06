class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/agents/people')
    .description("Create a person agent")
    .params(["agent", JSONModel(:agent_person), "The person to create", :body => true])
    .permissions([:update_agent_record])
    .returns([200, :created],
             [400, :error]) \
  do
    handle_create(AgentPerson, :agent)
  end


  Endpoint.get('/agents/people')
    .description("List all person agents")
    .params()
    .paginated(true)
    .permissions([])
    .returns([200, "[(:agent_person)]"]) \
  do
    handle_listing(AgentPerson, params)
  end


  Endpoint.post('/agents/people/:agent_id')
    .description("Update a person agent")
    .params(["agent_id", Integer, "The ID of the agent to update"],
            ["agent", JSONModel(:agent_person), "The person to create", :body => true])
    .permissions([:update_agent_record])
    .returns([200, :updated],
             [400, :error]) \
  do
    handle_update(AgentPerson, :agent_id, :agent)
  end


  Endpoint.get('/agents/people/:id')
    .description("Get a person by ID")
    .params(["id", Integer, "ID of the person agent"],
            ["resolve", [String], "A list of references to resolve and embed in the response",
             :optional => true])
    .permissions([])
    .returns([200, "(:agent)"],
             [404, '{"error":"Agent not found"}']) \
  do
    json_response(resolve_references(AgentPerson.to_jsonmodel(AgentPerson.get_or_die(params[:id])),
                                     params[:resolve]))
  end


  Endpoint.delete('/agents/people/:id')
    .description("Delete an agent person")
    .params(["id", Integer, "ID of the person agent"])
    .permissions([:delete_agent_record])
    .returns([200, :deleted]) \
  do
    handle_delete(AgentPerson, params[:id])
  end


end

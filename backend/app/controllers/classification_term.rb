class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/classification_terms')
    .description("Create a Classification Term")
    .params(["classification_term", JSONModel(:classification_term), "The Classification Term to create", :body => true],
            ["repo_id", :repo_id])
    .permissions([:update_classification_record])
    .returns([200, :created],
             [400, :error],
             [409, '{"error":{"[:root_record_id, :ref_id]":["A Classification Term Ref ID must be unique to its resource"]}}']) \
  do
    handle_create(ClassificationTerm, :classification_term)
  end


  Endpoint.post('/repositories/:repo_id/classification_terms/:classification_term_id')
    .description("Update a Classification Term")
    .params(["classification_term_id", Integer, "The Classification Term ID to update"],
            ["classification_term", JSONModel(:classification_term), "The Classification Term data to update", :body => true],
            ["repo_id", :repo_id])
    .permissions([:update_classification_record])
    .returns([200, :updated],
             [400, :error],
             [409, '{"error":{"[:root_record_id, :ref_id]":["A Classification Term Ref ID must be unique to its resource"]}}']) \
  do
    handle_update(ClassificationTerm, :classification_term_id, :classification_term)
  end


  Endpoint.post('/repositories/:repo_id/classification_terms/:classification_term_id/parent')
    .description("Set the parent/position of a Classification Term in a tree")
    .params(["classification_term_id", Integer, "The Classification Term ID to update"],
            ["parent", Integer, "The parent of this node in the tree", :optional => true],
            ["position", Integer, "The position of this node in the tree", :optional => true],
            ["repo_id", :repo_id])
    .permissions([:update_classification_record])
    .returns([200, :updated],
             [400, :error]) \
  do
    obj = ClassificationTerm.get_or_die(params[:classification_term_id])
    obj.update_position_only(params[:parent], params[:position])

    updated_response(obj)
  end


  Endpoint.get('/repositories/:repo_id/classification_terms/:classification_term_id')
    .description("Get a Classification Term by ID")
    .params(["classification_term_id", Integer, "The Classification Term ID"],
            ["repo_id", :repo_id],
            ["resolve", [String], "A list of references to resolve and embed in the response",
             :optional => true])
    .permissions([:view_repository])
    .returns([200, "(:classification_term)"],
             [404, '{"error":"ClassificationTerm not found"}']) \
  do
    json = ClassificationTerm.to_jsonmodel(params[:classification_term_id])

    json_response(resolve_references(json, params[:resolve]))
  end


  Endpoint.get('/repositories/:repo_id/classification_terms/:classification_term_id/children')
    .description("Get the children of a Classification Term")
    .params(["classification_term_id", Integer, "The Classification Term ID"],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "a list of classification term references"],
             [404, '{"error":"ClassificationTerm not found"}']) \
  do
    ao = ClassificationTerm.get_or_die(params[:classification_term_id])
    json_response(ao.children.map {|child|
      ClassificationTerm.to_jsonmodel(child)})
  end


  Endpoint.get('/repositories/:repo_id/classification_terms')
    .description("Get a list of Classification Terms for a Repository")
    .params(["repo_id", :repo_id])
    .paginated(true)
    .permissions([:view_repository])
    .returns([200, "[(:classification_term)]"]) \
  do
    handle_listing(ClassificationTerm, params)
  end


  Endpoint.delete('/repositories/:repo_id/classification_terms/:classification_term_id')
    .description("Delete a Classification Term")
    .params(["classification_term_id", Integer, "The Classification Term to delete"],
            ["repo_id", :repo_id])
    .permissions([:delete_classification_record])
    .returns([200, :deleted]) \
  do
    handle_delete(ClassificationTerm, params[:classification_term_id])
  end

end

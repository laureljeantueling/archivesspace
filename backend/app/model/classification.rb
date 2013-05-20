class Classification < Sequel::Model(:classification)
  include ASModel
  include Relationships
  include Trees

  corresponds_to JSONModel(:classification)
  set_model_scope(:repository)

  tree_of(:classification, :classification_term)

  define_relationship(:name => :classification_creator,
                      :json_property => 'creator',
                      :contains_references_to_types => proc {
                        AgentManager.registered_agents.map {|a| a[:model]}
                      },
                      :is_array => false)
end
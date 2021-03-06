require 'time'

class Event < Sequel::Model(:event)

  include ASModel
  corresponds_to JSONModel(:event)

  include Relationships
  include Agents

  agent_role_enum("linked_agent_event_roles")

  set_model_scope :repository

  enable_suppression

  one_to_many :date, :class => "ASDate"
  def_nested_record(:the_property => :date,
                    :contains_records_of_type => :date,
                    :corresponding_to_association => :date,
                    :is_array => false,
                    :always_resolve => true)

  define_relationship(:name => :event_link,
                      :json_property => 'linked_records',
                      :contains_references_to_types => proc {[Accession, Resource, ArchivalObject, DigitalObject, AgentPerson, AgentCorporateEntity, AgentFamily, AgentSoftware]},
                      :class_callback => proc { |clz|
                        clz.instance_eval do
                          include DynamicEnums

                          uses_enums({
                                       :property => 'role',
                                       :uses_enum => 'linked_event_archival_record_roles'
                                     })
                        end
                      })


  def has_active_linked_records?
    linked_records(:event_link).each do |linked_record|
      if linked_record.values.has_key?(:suppressed) && linked_record[:suppressed] == 0
        return true
      end
    end

    return false
  end


  # Look for events that link to a given record.  If we find any, consider
  # suppressing them if they have no active linked records
  def self.handle_suppressed(record)
    events = instances_relating_to(record)

    events.each do |event|
      val = !event.has_active_linked_records?
      event.set_suppressed(val)
    end
  end


  def set_suppressed(suppress)
    self.suppressed = (suppress ? 1 : 0)
    save

    suppress
  end


  def self.sequel_to_jsonmodel(obj, opts = {})
    json = super

    if json['timestamp']
      json['timestamp'] = json['timestamp'].iso8601
    end

    json
  end


  #
  # Some canned creators for system generated events
  #

  def self.for_component_transfer(archival_object_uri, source_resource_uri, target_resource_uri)
    # first get the current user
    user = User[:username => RequestContext.get(:current_username)]

    # build event
    event = JSONModel(:event).from_hash({
                                          "event_type" => "component_transfer",
                                          "timestamp" => Time.now.utc.iso8601,
                                          "linked_records" => [
                                            {"role" => "source", "ref" => source_resource_uri},
                                            {"role" => "outcome", "ref" => target_resource_uri},
                                            {"role" => "transfer", "ref" => archival_object_uri},
                                          ],
                                          "linked_agents" => [
                                            {"role" => "implementer", "ref" => JSONModel(:agent_person).uri_for(user.agent_record_id)}
                                          ]
                                        })

    # save the event to the DB in the global context
    self.create_from_json(event, :system_generated => true)
  end


  def self.for_cataloging(agent_uri, record_uri)
    #build event
    event = JSONModel(:event).from_hash(
      :linked_agents => [{:ref => agent_uri, :role => 'implementer'}],
      :event_type => 'cataloged',
      :timestamp => Time.now.utc.iso8601,
      :linked_records => [{:ref => record_uri, :role => 'outcome'}]
    )


    RequestContext.in_global_repo do
      Event.create_from_json(event, :system_generated => true)
    end
  end


  def self.for_archival_record_merge(target, victims)
    user = User[:username => RequestContext.get(:current_username)]

    merge_note = ""
    victims.each do |victim|
      victim_json = victim.class.to_jsonmodel(victim)

      if victim_json['identifier']
        identifier = Identifiers.format(Identifiers.parse(victim_json['identifier']))
      else
        identifier = victim_json['digital_object_id']
      end

      merge_note += (identifier +
                     " -- " +
                     victim_json['title'] +
                     "\n")
    end

    event = JSONModel(:event).from_hash(
      :linked_agents => [{
                           "role" => "implementer",
                           "ref" => JSONModel(:agent_person).uri_for(user.agent_record_id)
                         }],
      :event_type => 'component_transfer',
      :outcome => 'pass',
      :outcome_note => merge_note,
      :timestamp => Time.now.utc.iso8601,
      :linked_records => [{:ref => target.uri, :role => 'outcome'}]
    )

    Event.create_from_json(event, :system_generated => true)
  end


end

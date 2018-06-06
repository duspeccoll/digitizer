class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/archival_objects/:id/digitize')
    .description("Create a digital object representation for an item record")
    .params(["id", :id],
            ["repo_id", :repo_id])
    .permissions([:update_digital_object_record])
    .returns([200, "OK"]) \
  do
    json_response(digitize_item(params[:id], params[:repo_id]))
  end

  private

  def create_digital_object(item)
    links = item['external_documents'].select {|e| e['title'] == "Special Collections @ DU"}
    digital_object_id = links.empty? ? item['component_id'] : links[0]['location']

    obj = JSONModel(:digital_object).new({
      :title => item['title'],
      :digital_object_id => digital_object_id,
      :publish => true
    })

    handle_create(DigitalObject, obj)
  end

  def link_to_item(id, item, ref)
    instance = JSONModel(:instance).new({
      :instance_type => "digital_object",
      :is_representative => true,
      :digital_object => { :ref => ref }
    })

    item['instances'].push(instance)
    handle_update(ArchivalObject, id, item)
  end

  def digitize_item(id, repo_id)
    json = {}
    item = ArchivalObject.to_jsonmodel(id)

    if item['instances'].select{|i| i['instance_type'] == "digital_object"}.empty?
      obj = create_digital_object(item)
      ref = JSONModel(:digital_object).uri_for(JSON.parse(obj[2][0])['id'], :repo_id => repo_id)
      obj = link_to_item(id, item, ref)

      json['status'] = "linked"
      json['archival_object'] = JSONModel(:archival_object).uri_for(id, :repo_id => repo_id)
      json['digital_object'] = ref
    else
      json['alert'] = "A digital object already exists"
      json['id'] = id
    end

    return json
  end

end

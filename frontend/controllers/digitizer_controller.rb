class DigitizerController < ApplicationController

  set_access_control "update_digital_object_record" => [:index, :search, :update]

  def index
  end

  def search
    if params['item'].nil?
      flash[:error] = "No item selected"
      redirect_to :action => :index
    else
      params['ref'] = params['item']['ref'] if params['ref'].nil?
      @results = do_search(params)
    end
  end

  def update
    @results = do_update(params)
  end

  private

  def is_blank?(s)
    (s.nil? || s.empty?) ? true : false
  end

  def do_search(params)
    ref = params['ref']
    json = JSONModel::HTTP::get_json(ref)

    results = {
      'title' => json['title'],
      'uri' => ref,
      'id' => JSONModel(:archival_object).id_for(ref),
      'identifier' => json['component_id']
    }

    urls = json['external_documents'].select { |d| d['title'] == "Special Collections @ DU" }
    results['url'] = urls.first['location'] unless urls.nil? or urls.empty?

    digital_objects = json['instances'].select { |i| i['instance_type'] == "digital_object" && i['is_representative'] }
    unless digital_objects.nil? or digital_objects.empty?
      digital_object_ref = digital_objects.first['digital_object']['ref']
      digital_object = JSONModel::HTTP::get_json(digital_object_ref)

      results['digital_object'] = {
        'uri' => digital_object_ref,
        'digital_object_type' => digital_object['digital_object_type']
      }
    end

    results
  end

  def do_update(params)
    results = {'title' => params['title']}

    item = JSONModel(:archival_object).find(JSONModel(:archival_object).id_for(params['uri']))

    # perform updates if a digital object is attached; create a new one and attach it to the item if not
    if params.has_key?('digital_object_ref')
      dao = JSONModel(:digital_object).find(JSONModel(:digital_object).id_for(params['digital_object_ref']))

      if dao['digital_object_id'] == params['url']
        results['digital_object'] = {'info' => "Digital Object already has that identifier"}
      else
        dao['digital_object_id'] = params['url']
        results['digital_object'] = post_digital_object(params['digital_object_ref'], dao.to_json)
        if results['digital_object'].has_key?('success')
          links = item['external_documents'].select { |d| d['title'] == "Special Collections @ DU" }
          if links.empty?
            item['external_documents'].push(JSONModel(:external_document).new({
              'title' => "Special Collections @ DU",
              'location' => params['url']
            }))
          else
            if links.first['location'] != params['url']
              item['external_documents'].each {|d| d['location'] = params['url'] if d['title'] == "Special Collections @ DU"}
            end
          end
          results['item'] = post_item(params['uri'], item.to_json)
        end
      end
    else
      dao = JSONModel(:digital_object).new({
        'title' => item['title'],
        'publish' => true
      })
      dao['digital_object_type'] = params['digital_object_type'] if params.has_key?('digital_object_type')
      dao['digital_object_id'] = is_blank?(params['url']) ? item['component_id'] : params['url']
      results['digital_object'] = post_digital_object(nil, dao.to_json)

      if results['digital_object'].has_key?('success')
        instance = JSONModel(:instance).new({
          'instance_type' => "digital_object",
          'is_representative' => true,
          'digital_object' => {'ref' => results['digital_object']['success']}
        })
        item['instances'].push(instance)
        results['item'] = post_item(params['uri'], item.to_json)
      end
    end

    results
  end

  def post_json(uri, json)
    resp = JSONModel::HTTP.post_json(uri, json)
    if resp.code == '200'
      results = {'success' => ASUtils.json_parse(resp.body)['uri']}
    else
      results = {'error' => ASUtils.json_parse(resp.body)['error']}
    end

    results
  end

  def post_item(ref, json)
    uri = URI("#{JSONModel::HTTP.backend_url}#{ref}")
    post_json(uri, json)
  end

  def post_digital_object(ref, json)
    url = JSONModel::HTTP.backend_url
    url += ref.nil? ? "/repositories/#{session[:repo_id]}/digital_objects" : ref

    uri = URI(url)
    post_json(uri, json)
  end
end

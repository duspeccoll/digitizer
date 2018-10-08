class DigitizerController < ApplicationController

  set_access_control "update_digital_object_record" => [:index]

  def index
    id = JSONModel(:archival_object).id_for(params[:record_uri])
    item = JSONModel(:archival_object).find(id)

    link_digital_object(params[:record_uri])
  end

  private

  def link_digital_object(record_uri)
    resp = JSONModel::HTTP.post_form("#{record_uri}/digitize")

    if resp.code === "200"
      json = ASUtils.json_parse(resp.body)
      if json.has_key?('alert')
        flash[:alert] = json['alert']
      else
        flash[:success] = "Digital object #{json['digital_object']} linked to #{json['archival_object']}"
      end
      redirect_to(:controller => :digital_objects, :action => :edit, :id => JSONModel(:digital_object).id_for(json['digital_object']))
    else
      flash[:error] = json['error']
      redirect_to(:controller => :resources, :action => :edit, :id => JSONModel(:resource).id_for(item['resource']['ref']), :anchor => "tree::archival_object_#{id}")
    end
  end
end

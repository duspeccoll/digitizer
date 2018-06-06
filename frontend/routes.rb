ArchivesSpace::Application.routes.draw do
  match('/plugins/digitizer' => 'digitizer#index', :via => [:post])
end

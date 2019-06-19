ArchivesSpace::Application.routes.draw do
  match('/plugins/digitizer' => 'digitizer#index', :via => [:get])
  match('/plugins/digitizer/search' => 'digitizer#search', :via => [:post])
  match('/plugins/digitizer/update' => 'digitizer#update', :via => [:post])
end

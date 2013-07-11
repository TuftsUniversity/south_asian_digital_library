ALLOW_DOTS ||= /[a-zA-Z0-9_.:]+/

SouthAsianDigitalLibrary::Application.routes.draw do
  root :to => "catalog#index"

  Blacklight.add_routes(self)
   resources :catalog, :only => [:show, :update], :constraints => { :id => ALLOW_DOTS, :format => false }
   Blacklight::Routes.new(self, {}).catalog
   resources :unpublished, :only => :index
   # This is from Blacklight::Routes#solr_document, but with the constraints added which allows periods in the id
   resources :solr_document,  :path => 'catalog', :controller => 'catalog', :only => [:show, :update]
   resources :downloads, :only =>[:show], :constraints => { :id => ALLOW_DOTS
  }
  resources :bookmarks, :path => 'catalog'
  resources :search_history, :path => 'search_history', :only => [:index,:show]

   HydraHead.add_routes(self)

   #mount HydraEditor::Engine => '/'
   post 'records/:id/publish', to: 'records#publish', as: 'publish_record', constraints: { id: ALLOW_DOTS }

   resources :records, only: [:destroy], constraints: { id: ALLOW_DOTS } do
     member do
       delete 'cancel'
     end
     resources :attachments, constraints: { id: ALLOW_DOTS }
   end

   resources :generics, only: [:edit, :update], constraints: { id: ALLOW_DOTS }

   devise_for :users
  # mount Hydra::RoleManagement::Engine => '/'

#  Blacklight.add_routes(self)
#  HydraHead.add_routes(self)

  #devise_for :users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
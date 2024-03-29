Eda::Application.routes.draw do
    root :to => 'static_pages#home'

    devise_for :users

    resources :editions do
        resources :works do
            member do
                post :add_to_reading_list
            end
        end
        resources :image_sets, only: [:index, :show, :edit, :update] do
            collection do
                post :rebuild
                post :expand_node
            end
            resources :works
        end
        resources :work_sets do
            collection do
                post :rebuild
            end
        end
    end

    resources :images do
        member do
            get '/download' => 'images#download', :as => :download
        end
    end

    resources :image_sets do
        resources :notes
    end

    resources :reading_lists do
        collection do
            post :rebuild
        end
    end

    resources :collections, only: [:index, :show] do
        resources :image_sets
        collection do
            post :expand_node
        end
    end

    resources :works do
        resources :image_sets do
            collection do
                post :rebuild
            end
        end
        member do
            get '/edit/edition' => 'works#choose_edition', :as => :choose_edition
            get :metadata
        end
        collection do
            get '/new/edition' => 'works#choose_edition', :as => :choose_edition_new
            match '/:first_letter' => 'works#browse', :as => :by_letter, :first_letter => /[A-Za-z]/, via: [:get, :post]
        end
    end
    resources :words do
        collection do
            match '/:first_letter' => 'words#index', :as => :by_letter, :first_letter => /[A-Za-z]/, via: [:get, :post]
        end
    end

    match 'about' => 'static_pages#about', via: [:get, :post]
    match 'use' => 'static_pages#use', via: [:get, :post]
    match 'faq' => 'static_pages#faq', via: [:get, :post]
    match 'resources' => 'static_pages#resources', via: [:get, :post]
    match 'team' => 'static_pages#team', via: [:get, :post]
    match 'terms' => 'static_pages#terms', via: [:get, :post]
    match 'privacy' => 'static_pages#privacy', via: [:get, :post]
    match 'contact' => 'static_pages#contact', via: [:get, :post]

    match 'lexicon' => 'words#index', via: [:get, :post]

    match 'search(/:q)' => 'works#search', :as => 'search_works', via: [:get, :post]

    get 'my_notes' => 'users#my_notes'
    get 'my_reading_lists' => 'users#my_reading_lists'

    mount OaiRepository::Engine => "/oai"

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

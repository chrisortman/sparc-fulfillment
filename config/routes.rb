Rails.application.routes.draw do

  devise_for :users

  resources :protocols
  resources :procedures, only: [:create, :edit, :update, :destroy]
  resources :notes, only: [:index, :new, :create]

  resources :visit_groups do
    collection do
      get 'position_update_options', to: 'visit_groups#position_update_options'
    end
  end

  resources :arms, only: [:new, :create, :destroy] do
    member do
      get 'refresh_vg_dropdown'
    end
  end

  resources :participants do
    get 'change_arm(/:id)', to: 'participants#edit_arm'
    post 'change_arm(/:id)', to: 'participants#update_arm'
    get 'details', to: 'participants#details'
    patch 'set_recruitment_source', to: 'participants#set_recruitment_source'
  end

  resources :tasks do
    member do
      get 'task_reschedule'
    end
  end

  resources :appointments do
    collection do
      get 'completed_appointments'
    end
  end

  resources :custom_appointments, :controller => :appointments

  resources :multiple_line_items, only: [] do
    collection do
      get 'new_line_items'
      get 'edit_line_items'
      get 'necessary_arms'
      put 'update_line_items'
    end
  end

  resources :service_calendar, only: [] do
    collection do
      get 'change_page'
      get 'change_tab'
      put 'check_visit'
      put 'change_quantity'
      put 'change_visit_name'
      get 'edit_service'
      patch 'update_service'
      put 'check_row'
      put 'check_column'
      put 'remove_line_item'
    end
  end

  mount API::Base => '/'

  root 'protocols#index'
end




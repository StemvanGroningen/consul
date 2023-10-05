Rails.application.routes.draw do
  mount Ckeditor::Engine => "/ckeditor"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  draw :account
  draw :admin
  draw :budget
  draw :comment
  draw :community
  draw :debate
  draw :devise
  draw :direct_upload
  draw :document
  draw :graphql
  draw :legislation
  draw :management
  draw :moderation
  draw :notification
  draw :officing
  draw :poll
  draw :proposal
  draw :related_content
  draw :sdg
  draw :sdg_management
  draw :tag
  draw :user
  draw :valuation
  draw :verification

  root "welcome#index"
  get "/welcome", to: "welcome#welcome"
  get "/consul.json", to: "installation#details"
  get "robots.txt", to: "robots#index"

  resources :stats, only: [:index]
  resources :images, only: [:destroy]
  resources :documents, only: [:destroy]
  resources :follows, only: [:create, :destroy]
  resources :remote_translations, only: [:create]

  # More info pages
  get "help",             to: "pages#show", id: "help/index",             as: "help"

  get "help/how-to-use",  to: "pages#show", id: "help/how_to_use/index",  as: "how_to_use"
  get "help/faq",         to: "pages#show", id: "faq",                    as: "faq"

  # Custom routes
  get "stemvantenboer", to: redirect("/budgets/10")
  get "garmerwolde", to: redirect("/budgets/10/investments?heading_id=8")
  get "lellens", to: redirect("/budgets/10/investments?heading_id=9")
  get "sintannen", to: redirect("/budgets/10/investments?heading_id=10")
  get "tenboer", to: redirect("/budgets/10/investments?heading_id=11")
  get "thesinge", to: redirect("/budgets/10/investments?heading_id=12")
  get "winneweer", to: redirect("/budgets/10/investments?heading_id=13")
  get "wittewierum", to: redirect("/budgets/10/investments?heading_id=14")
  get "tenpost", to: redirect("/budgets/10/investments?heading_id=15")
  get "woltersum", to: redirect("/budgets/10/investments?heading_id=16")
  get "beijumbruist", to: redirect("/budgets/18")
  get "lewenborgleeft", to: redirect("/budgets/19")
  get "beweegplekmikkelhorst", to: redirect("/budgets/20")
  get "sterkhoogerk", to: redirect("/budgets/22")

  # Static pages
  resources :pages, path: "/", only: [:show]
end

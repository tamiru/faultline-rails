Rails.application.routes.draw do
  mount Faultline::Engine => "/faultline"
end

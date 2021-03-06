#
#The MIT License (MIT)
#
#Copyright (c) 2016, Groupon, Inc.
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#
require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq"

  namespace :api do
    match 'oauth/callback' => 'oauth#callback', :via => :get
    match 'oauth/authorize' => 'oauth#authorize', :via => :get
    match 'oauth/user' => 'oauth#user', :via => :get

    resources :service, :only => [:index, :show] do
      member do
        get 'stats'
        match 'stats/history' => 'service#history', :via => :get
        match 'stats/burns' => 'service#burns', :via => :get
        match 'stats/history/range' => 'service#history_range', :via => :get
        match 'stats/history/resolution' => 'service#history_resolution', :via => :get
      end
    end

    resources :filter, :only => [:index, :show, :create, :destroy]
    resources :burn, :only => [:index, :show, :create]

    resources :finding, :only => [:index, :show, :update] do
      put 'publish', on: :member
    end

    resources :stats, :only => [:index] do
      collection do
        get 'burns'
        match "/history" => "stats#history", :via => :get
        match "/history/range" => "stats#range", :via => :get
        match "/history/resolution" => "stats#resolution", :via => :get
      end
    end

    match 'settings' => 'settings#index', :via => :get
    match 'settings' => 'settings#update', :via => :post
    match 'settings/admin' => 'settings#admin_list', :via => :get
    match 'settings/admin' => 'settings#admin_update', :via => :post

    match 'github/search/:type' => 'github#search', :via => :get
  end
end

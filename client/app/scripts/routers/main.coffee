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
'use strict'

class Codeburner.Routers.Main extends Backbone.Router
  initialize: (serviceCollection) ->
    @findingCollection = new Codeburner.Collections.Finding
    @findingListView = new Codeburner.Views.FindingList @findingCollection, serviceCollection

    @burnCollection = new Codeburner.Collections.Burn
    @burnListView = new Codeburner.Views.BurnList @burnCollection, serviceCollection

    @filterCollection = new Codeburner.Collections.Filter
    @filterListView = new Codeburner.Views.FilterList @filterCollection, serviceCollection

    @statsView = new Codeburner.Views.Stats serviceCollection

    @settingsView = new Codeburner.Views.Settings

    @defaultView = new Codeburner.Views.Default

  routes:
    'findings?*queryString': 'findingsAction'
    'findings': 'findingsAction'
    'filters': 'filtersAction'
    'stats': 'statsAction'
    'settings': 'settingsAction'
    'burns': 'burnsAction'
    '*query': 'defaultAction'

  execute: (callback, args, name) ->
    if args[1]?
      @checkAuthz args[1]

    do @resetViews

    $('.nav-item').removeClass('active')
    $("#nav-#{name.split("Action")[0]}").addClass('active')

    callback.apply(this, args) if callback

  checkAuthz: (query) ->
    if query?
      parsedQuery = Codeburner.Utilities.parseQueryString(query)

      unless parsedQuery.authz == undefined
        localStorage.setItem "authz", parsedQuery.authz

        Codeburner.Utilities.getRequest "/api/oauth/user", ((data) =>
          Codeburner.User = data
          Codeburner.Utilities.authz()

          if localStorage.getItem "authRedirect"
            window.location.hash = localStorage.getItem("authRedirect")
            localStorage.removeItem "authRedirect"

        ), (data) ->
          Codeburner.User = null
          console.log "invalid authz token"

  resetViews: ->
    views = Object.keys(window.router).filter((key) =>
        window.router[key] instanceof Backbone.View
      )

    for view in views
      do window.router[view].undelegateEvents
      do window.router[view].clearRefreshInterval if typeof(window.router[view].clearRefreshInterval) == 'function'

  findingsAction: (query) ->
    if query?
      do @findingCollection.resetFilter
      @findingCollection.filters = _.extend @findingCollection.filters, Codeburner.Utilities.parseQueryString(query)
      do @findingCollection.changeFilter

    do @findingListView.render

  filtersAction: (query) ->
    do @filterListView.render

  statsAction: (query) ->
    do @statsView.render

  settingsAction: (query) ->
    do @settingsView.render

  burnsAction: (query) ->
    do @burnListView.render

  defaultAction: (action, query) ->
    do @defaultView.render

$ ->
  Codeburner.Utilities.checkAuthz window.location.hash
  Codeburner.Utilities.authz()

  serviceCollection = new Codeburner.Collections.Service

  serviceCollection.fetch().done =>
    window.router = new Codeburner.Routers.Main serviceCollection
    do $.material.init
    do Backbone.history.start

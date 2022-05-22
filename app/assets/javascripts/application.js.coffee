# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
# vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file. JavaScript code in this file should be added after the last require_* statement.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require popper
#= require turbolinks
#= require jquery3
#= require bootstrap-sprockets
#= require_tree ./channels
#= require_tree .

document.addEventListener 'turbolinks:load', ->
  # a click on a nav-link adds an anchor to the url and sets the page parameter to 1 if present
  $('.nav-link').on 'click', (e) ->
    window.history.replaceState(null, null, "#{$(this).attr('href')}")
    url = new URL(window.location.href)
    if url.href.includes('page') and url.searchParams.get('page') != 1
      url.searchParams.set('page', 1)
      window.location.href = url.href

  # get anchor from url and activate the correct nav-link
  anchor = window.location.href.split('#')[1]
  if anchor
    $('.nav-link.active').removeClass('active')
    $('.tab-pane.active').removeClass('active').removeClass('show')
    $("##{anchor}-tab").addClass('active')
    $("##{anchor}").addClass('active').addClass('show')
    $(window).scrollTop(0)  # workaround to prevent scroll from anchor tag

  # a click on a component-column links to its show
  openUrl = (t, e, middle_btn) ->
    $et = $(e.target);
    $t = $(t);
    unless $et.hasClass('admin-actions__link__icon') || $et.hasClass('btn-square')
      external_url = $t.attr('data-external_url');
      internal_url = $t.attr('data-internal_url');
      protocol_and_host = window.location.protocol + '//' + window.location.host;
      if external_url
        if typeof gtag == 'function'
          gtag('event', 'click', { 'event_category': 'external_url', 'event_label': external_url });
        window.open(external_url, '_blank');
      else if internal_url
        if middle_btn
          window.open(protocol_and_host + internal_url, '_blank');
        else
          window.location.href = internal_url;
      else
        id = $t.attr('data-id');
        if id != undefined
          component = $t.attr('data-component');
          path = "/#{component}s/#{id}";
          if middle_btn
            window.open(protocol_and_host + path, '_blank');
          else
            window.location.href = path;
  $('tbody.with-show').on 'auxclick', 'tr', (e) ->
    if e.button == 1 # allow only the middle button
      openUrl(this, e, true);
  $('tbody.with-show').on 'click', 'tr', (e) ->
    openUrl(this, e, (e.button == 1));

  # a click on sort table header toggels its order param
  $('th a').on 'click', (e) ->
    wlhref = window.location.href
    if wlhref.includes('order=') && this.href.includes('order=')
      if wlhref.includes('order=asc')
        this.href = this.href.replace('order=asc', 'order=desc')
      else if wlhref.includes('order=desc')
        this.href = this.href.replace('order=desc', 'order=asc')

  $('.scroll-top').on 'click', (e) ->
    $('html, body').animate({
      scrollTop: 0
    }, 500)

  $('.toast').toast({delay: 10000}).toast('show')

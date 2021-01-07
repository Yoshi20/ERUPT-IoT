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
#= require bootstrap
#= require bootstrap-sprockets
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

  $('.scroll-top').on 'click', (e) ->
    $('html, body').animate({
      scrollTop: 0
    }, 500)

  $('.toast').toast({delay: 10000}).toast('show')

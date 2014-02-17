#= require jquery
#= require jquery_ujs
#= require chroma.min
#= require aws-sdk-2.0.0-rc9.min.js
#= require_tree ./models

##############################################################################################################
# On Ready   
##############################################################################################################
$(document).on 'ready', ->
  new TRAX.Editor($('[data-editor]'));

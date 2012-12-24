#= require submodule

conditional_alert = (message, condition) ->
  custom_alert message if condition

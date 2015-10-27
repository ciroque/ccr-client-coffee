window.Utils = class @Utils
  @sleep: (ms) ->
    start = new Date().getTime()
    continue while new Date().getTime() - start < ms

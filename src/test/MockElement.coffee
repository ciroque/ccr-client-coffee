"use strict"

window.MockElement = class MockElement
  constructor: () ->
    @children = []
    @html = ''

  html: (html) ->
    @html = html

  append: (child) ->
    @children.push(child)

  empty: () ->
    @children = []

  dumpChildren: () ->
    console.log("#{i}) #{child}") for child, i in @children
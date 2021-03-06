eco       = require ".."
{fixture} = require "./lib/fixtures"

items = [
  { name: "Caprese", price: "5.25"},
  { name: "Artichoke", price: "6.25" }
]

module.exports =
  "eco() caches compiled templates": (test) ->
    render = eco fixture("hello.eco")
    test.same render, eco fixture("hello.eco")
    test.done()

  "cache can be disabled": (test) ->
    cache = eco.cache
    eco.cache = false
    render = eco fixture("hello.eco")
    test.ok render isnt eco fixture("hello.eco")
    eco.cache = cache
    test.done()

  "eco.preprocess": (test) ->
    test.same fixture("hello.coffee"), eco.preprocess fixture("hello.eco")
    test.done()

  "eco.precompile": (test) ->
    js = eco.precompile "Hello <%= @name %>"
    test.ok typeof js is "string"
    fn = eval "(#{js})"
    test.ok typeof fn is "function"
    test.same "Hello Sam", fn name: "Sam"
    test.done()

  "compiling hello.eco": (test) ->
    render = eco.compile fixture("hello.eco")
    test.same fixture("hello.out.1"), render name: "Sam"
    test.done()

  "compiled templates can be reused": (test) ->
    render = eco.compile "Hello <%= @name %>"
    test.same "Hello Sam", render name: "Sam"
    test.same "Hello Josh", render name: "Josh"
    test.done()

  "eco.compile bypasses cache": (test) ->
    test.ok eco.cache
    render = eco.compile fixture("hello.eco")
    test.ok render isnt eco.compile fixture("hello.eco")
    test.done()

  "rendering hello.eco": (test) ->
    output = eco.render fixture("hello.eco"), name: "Sam"
    test.same fixture("hello.out.1"), output
    test.done()

  "rendering hello.eco without a name throws an exception": (test) ->
    test.expect 1
    try
      eco.render fixture("hello.eco")
    catch err
      test.ok err
    test.done()

  "rendering projects.eco with empty projects array": (test) ->
    output = eco.render fixture("projects.eco"), projects: []
    test.same fixture("projects.out.1"), output
    test.done()

  "rendering projects.eco with multiple projects": (test) ->
    output = eco.render fixture("projects.eco"), projects: [
      { name: "PowerTMS Active Shipments Page Redesign", url: "/projects/1" },
      { name: "SCU Intranet", url: "/projects/2", description: "<p><em>On hold</em></p>" },
      { name: "Sales Template", url: "/projects/3" }
    ]
    test.same fixture("projects.out.2"), output
    test.done()

  "rendering helpers.eco": (test) ->
    output = eco.render fixture("helpers.eco"),
      items: items
      contentTag: (tagName, attributes, callback) ->
        attrs = (" #{name}=\"#{value}\"" for name, value of attributes)
        @safe "<#{tagName}#{attrs.join("")}>#{callback()}</#{tagName}>"

    test.same fixture("helpers.out.1"), output
    test.done()

  "rendering capture.eco": (test) ->
    output = eco.render fixture("capture.eco"), items: items
    test.same fixture("capture.out.1"), output
    test.done()

  "HTML is escaped by default": (test) ->
    output = eco.render "<%= @emailAddress %>",
      emailAddress: "<sstephenson@gmail.com>"

    test.same "&lt;sstephenson@gmail.com&gt;", output
    test.done()

  "unescaped HTML can be rendered from a helper": (test) ->
    output = eco.render "<%= @helper() %>",
      helper: -> @safe "<boo>"

    test.same "<boo>", output
    test.done()

  "escape method can be overridden": (test) ->
    output = eco.render "<%= @emailAddress %>",
      emailAddress: "<sstephenson@gmail.com>"
      escape: (string) ->
        string.toUpperCase()

    test.same "<SSTEPHENSON@GMAIL.COM>", output
    test.done()

  "'undefined' is never coerced into a string": (test) ->
    test.same "", eco.render "<%= @x %>"
    test.same "", eco.render "<%= @safe @x %>"
    test.same "", eco.render "<%- @x %>"
    test.done()

  "rendering an escaped <%": (test) ->
    test.same "<%", eco.render "<%%"
    test.done()

  "rendering an escaped %>": (test) ->
    test.same "%>", eco.render "%%>"
    test.done()

  "requiring eco templates as modules": (test) ->
    hello = require __dirname + "/fixtures/hello.eco"
    test.ok typeof hello is "function"
    test.same fixture("hello.out.1"), hello name: "Sam"

    test.done()

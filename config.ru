require File.expand_path '../app.rb', __FILE__

run Rack::URLMap.new({
  "/a1" => Protected::A1,
  "/a2" => Protected::A2,
  "/b" => Protected::B
})

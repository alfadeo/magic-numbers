#!/usr/bin/env ruby
require 'json'
require 'securerandom'
require 'rack'

@images = []
@durations = []

def euclid scaled_properties
  sq = scaled_properties[0].zip(scaled_properties[1]).map{|a,b| (a - b) ** 2}
  Math.sqrt(sq.inject(0) {|s,c| s + c})
end

def dijkstra graph
  path = [0]
  vert = Array(1..graph.size-1)
  graph.each_with_index{|v,i| v[i] = Float::INFINITY}
  until vert.empty?
    d = vert.collect{|v| graph[path.last][v]}
    n = graph[path.last].index(d.min)
    path << n
    vert.delete n
  end
  path
end 

def durations
  pulses = SecureRandom.random_number(5)+2
  steps = 8
  nr = Dir["images/*"].size
  @durations = []
  error = 0
  last = 0
  (0..steps-1).each do |i|
    error += pulses
    if error > 0 
      error -= steps
      @durations[i] = 1
      last = i
    else
      @durations[last] += 1
    end
  end
  @durations.compact!
  @durations += @durations until @durations.size > nr
  @durations = @durations[0..nr-1]
end

def reload
  fingerprints = {}
  `exiv2 -q -P v -g "Xmp.xmpMM.Fingerprint" #{Dir["images/*"].join " "}`.split("\n").each do |l|
    file,value_str = l.split(/\s+/)
    fingerprints[file] = JSON.parse value_str
  end
  n = fingerprints.keys.size - 1
  query_file = fingerprints.keys[SecureRandom.random_number(fingerprints.keys.size)]
  query_fingerprint = fingerprints[query_file]
  selection = fingerprints.collect{|f,fp| [f,euclid([query_fingerprint,fp])]}.sort{|a,b| a[1] <=> b[1]}.collect{|i| i[0]}[0..n]

  graph = []
  selection.each_with_index do |f,i|
    graph[i] ||= []
    (i..n).each do |j|
      graph[j] ||= []
      d = euclid([fingerprints[f],fingerprints[selection[j]]])
      graph[i][j] = d
      graph[j][i] = d
    end
  end
  @images = dijkstra(graph).collect{|n| selection[n]}
end

def html
  if !@images or @images.empty?
    reload
    durations
    "<html>
      <head> <meta http-equiv='refresh' CONTENT='5'> </head>
      <body bgcolor='black' text='white' style='text-align:center'>
        <h1 style='font-size:400%; margin-top:18%;'>Magic Numbers</h1>
        <h2 style='font-size:200%'>Find the secret message!</h2>
        <p style='margin-top:5%'> &copy; <a href=mailto:void@alfadeo.de>void@alfadeo.de</a>, Source code: <a href=https://github.com/alfadeo/magic-numbers>https://github.com/alfadeo/magic-numbers</a> </p>
      </body>
    </html>"
  else
    "<html>
        <head> <meta http-equiv='refresh' CONTENT='#{@durations.shift*2}'> </head>
        <body bgcolor='black'> <center><img src='/#{@images.shift}' height='100%'></center> </body>
    </html>"
  end
end

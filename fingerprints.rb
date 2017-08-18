require 'json'
fingerprints = {}
`exiv2 -q -P v -g "Xmp.xmpMM.Fingerprint" images/*`.split("\n").each do |l|
  f,fp = l.split(/\s+/)
  fingerprints[f] = JSON.parse fp
end

File.open("fingerprints.json","w+"){|f| f.puts fingerprints.to_json}

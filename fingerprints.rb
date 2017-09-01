require 'json'
fingerprints = {}
`exiv2 -q -P v -g "Xmp.xmpMM.Fingerprint" images/*`.split("\n").each do |l|
  f,fp = l.split(/\s+/)
  if fp
    fingerprints[f] = JSON.parse fp
  else
    s = `convert #{f} -resize 16x16! -depth 16 -colorspace RGB -compress none PGM:-`.split("\n")[3..-1]
    fingerprints[f] = s.collect{|l| l.split(" ").collect{|v| v.to_f}}.flatten
    `exiv2 -M"set Xmp.xmpMM.Fingerprint #{fingerprints[f].to_json}" #{f}`
  end
end

File.open("fingerprints.json","w+"){|f| f.puts fingerprints.to_json}

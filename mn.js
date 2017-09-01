images = []
durations = []
fingerprints = {}
slides = []
wait = 0
primes = [5,7,11,13]

function euclid_durations() {
  pulses = Math.floor(Math.random()*5)+2
  steps = 8
  nr = images.length
  error = 0
  last = 0
  for (i=0;i<steps;i++) {
    error += pulses
    if (error > 0) { 
      error -= steps
      durations[i] = 1
      last = i
    }
    else durations[last] += 1
  }
  durations = durations.filter(Number)
  while (durations.length < nr) { durations = durations.concat(durations) }
  durations = durations.slice(0,nr-1)
}

function euclid_distance(a, b) {
  sum = 0
  for (n = 0; n < a.length; n++) { sum += Math.pow(a[n] - b[n], 2) }
  return Math.sqrt(sum)
}

function slideshow() {
  setInterval(function () {
    if (wait > 0) wait-=1
    else if (slides.length == 0) {
      $('#h1').show()
      $('#h2').show()
      $('#sub').show()
      $('#image').hide()
      $.getJSON('fingerprints.json', function(data) {fingerprints = data})
      images = Object.keys(fingerprints)
      // random image
      start = images[Math.floor(Math.random()*images.length)]
      distances = []
      for (i=0;i<images.length;i++) {
        distances[i] = euclid_distance(fingerprints[start],fingerprints[images[i]])
      }
      // select nr_slides closest
      nr_slides = primes[Math.floor(Math.random()*4)]
      closest_idx = []
      for (i=0;i<distances.length;i++) closest_idx[i] = i;
      closest_idx.sort(function (a, b) { return distances[a] < distances[b] ? -1 : distances[a] > distances[b] ? 1 : 0; });
      closest_idx = closest_idx.slice(0,nr_slides)
      slides = closest_idx.map(function(x) { return images[x] })
      matrix = Array(slides.length)
      for (i=0;i<slides.length;i++) { matrix[i] = Array(slides.length) }
      for (i=0;i<slides.length;i++) {
        matrix[i][i] = Number.POSITIVE_INFINITY
        for(j=i;j<slides.length;j++) {
          d = euclid_distance(fingerprints[slides[i]],fingerprints[slides[j]])
          matrix[i][j] = d
          matrix[j][i] = d
        }
      }
      // dijkstra 
      path = [0]
      vert = []
      for (i=1;i<matrix.length;i++) { vert[i-1] = i }
      while (vert.length > 0) {
        d = vert.map(function(v) { return matrix[path[path.length-1]][v]})
        row = matrix[path[path.length-1]]
        min = Math.min(...d)
        n = row.indexOf(min)
        path.push(n)
        vert.splice(vert.indexOf(n),1)
      }
      euclid_durations()
      wait = 2
    }
    else {
      $('#h1').hide()
      $('#h2').hide()
      $('#sub').hide()
      $('#image').show()
      $('#image').attr("src",slides.shift())
      wait = durations.shift()
    }
  }, 1000);
}

$(document).ready(slideshow)

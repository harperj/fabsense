var input =[];
var input2 =[];
var margin = {top: 20, right: 80, bottom: 20, left: 51},
    width = 960 - margin.left - margin.right,
    height = 200 - margin.top - margin.bottom;

var parseDate = d3.time.format("%Y%m%d").parse;

var x = d3.time.scale()
    .range([0, width]);

var y = d3.scale.linear()
    .range([height, 0]);

var brush = d3.svg.brush()
    .x(x)
  .on("brush", brushed);  

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

var video;
var sensor_begin;
var video_begin;

function loadD3(metadata) {

  $("#annotateButton").on("click", function(event) {
    annotBrush();
    updateAnnotationText();
    addAnnotation(brush.extent()[0], brush.extent()[1]);
  });
	
	$("#readButton").on("click", function(event) {
		readAnnotationsFromText();
	});

	// MODIFY BELOW CODE TO CHANGE TO NEW DATASET
  var path = "data/"+ metadata.trial + "-" + metadata.folder +"/"+ metadata.trial + "-";
  d3.text(path + "times.txt", function(error, text) {
    video_begin = parseFloat(text.split("\n",1)[0]);
  });

  d3.csv(path + "sampled.csv", function(error, data) {
    sensor_begin = parseFloat(data[0]['timestamp']);
    buildTimeSeries(data, "acc", function(key) {return (key.charAt(0) == 'a');});
    buildTimeSeries(data, "gyr", function(key) {return (key.charAt(0) == 'g');});
    buildTimeSeries(data, "mag", function(key) {return (key.charAt(0) == 'm');});
  });

  d3.csv(path + "classified.csv", function(error, data){
  
  input = $.map(data, function(el, i){
      var start = parseInt(el.start) / 1000;
      var end = parseInt(el.finish) / 1000;
      return  start + "," + end;
   });
   console.log(input);
  });
	d3.csv(path + "annotations.csv", function(error, data){
  
  input2 = $.map(data, function(el, i){
      var start = parseInt(el.start) / 1000;
      var end = parseInt(el.finish) / 1000;
      return  start + "," + end;
   });
   console.log(input);
  });
	// MODIFY ABOVE CODE TO CHANGE TO NEW DATASET

  $("#videoFrame").on("timeupdate", function(t) {
    var video_time = t.currentTarget.currentTime;
		//console.log("Video Time: ", video_time);
    var sensor_time = video_begin + video_time
    if ((video_begin + video_time) < sensor_begin) {
      drawCursor(0);
    }
    else {
      drawCursor(video_begin + video_time);
    }
    
    if(brush.extent()[0].getTime() != brush.extent()[1].getTime()) {
      console.log("Past brush extent: " + ((sensor_time*1000) > brush.extent()[1].getTime()));
      if((sensor_time*1000) > brush.extent()[1].getTime()) {
        $("#videoFrame")[0].currentTime = brush.extent()[0].getTime()/1000 - video_begin;
      }
    }
    
  });
}

function drawCursor(timestamp) {
  d3.selectAll(".cursor").attr("x", function(d) {return x(new Date(timestamp*1000));});
}

function buildTimeSeries(data, divId, filter) {
	var color = d3.scale.category10(); 

  var line = d3.svg.line()
      .interpolate("basis")
      .x(function(d) { return x(d.timestamp); })
      .y(function(d) { return y(d.val); });

  var svg = d3.select("body").append("svg")
      .attr("id", divId)
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  color.domain(d3.keys(data[0]).filter(function(key) { return (key !== "timestamp") && filter(key); }));

  svg.append("defs").append("clipPath")
      .attr("id", "clip")
    .append("rect")
      .attr("width", width)
      .attr("height", height);

  var cities = color.domain().map(function(name) {
    return {
      name: name,
      values: data.map(function(d) {
        //console.log(d);
        return {timestamp: new Date(d.timestamp*1000), val: +d[name]};
      })
    };
  });

  x.domain(d3.extent(data, function(d) { return new Date(d.timestamp*1000); }));

  y.domain([
    d3.min(cities, function(c) { return d3.min(c.values, function(v) { return v.val; }); }),
    d3.max(cities, function(c) { return d3.max(c.values, function(v) { return v.val; }); })
  ]);

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Value");
      
  svg.append("g").append("rect").attr("class","cursor")
     .attr("x", x(new Date(sensor_begin)))
     .attr("y", 0)
     .attr("width", 1)
     .attr("height", 151);

  var city = svg.selectAll(".city")
      .data(cities)
    .enter().append("g")
      .attr("class", "city");

  city.append("path")
      .attr("class", "line")
      .attr("d", function(d) { return line(d.values); })
      .style("stroke", function(d) { return color(d.name); });

  city.append("text")
      .datum(function(d) { return {name: d.name, value: d.values[d.values.length - 1]}; })
      .attr("transform", function(d) { return "translate(" + x(d.value.timestamp) + "," + y(d.value.val) + ")"; })
      .attr("x", 3)
      .attr("dy", ".38em")
      .text(function(d) { return d.name; });
      
  svg.append("g")
         .attr("class", "x brush")
         .call(brush)
       .selectAll("rect")
         .attr("y", -6)
         .attr("height", height + 7);
  svg.append("g")
     .attr("class", "annotations");
}

function brushed() {
  d3.selectAll(".brush").call(brush);
  
  $("#videoFrame")[0].currentTime = brush.extent()[0].getTime()/1000 - video_begin;
}

function addAnnotation(time1, time2) {
  console.log([time1,time2]);
  d3.selectAll(".annotations").append("rect").attr("class","annot")
    .attr("x", x(time1))
    .attr("y", 0)
    .attr("width", x(time2) - x(time1))
    .attr("height", height);
}

function readAnnotationsFromText() {
  var annotationText = $("#annotationText").val();
  var lines = annotationText.split('\n');
  for (var i = 0; i < lines.length; ++i) {
    var vals = lines[i].split(',');
    addAnnotation(+vals[0]*1000, +vals[1]*1000);
  }
}

function skip(value) {
  console.log(video.get());
} 

function test() {
  console.log("testing");
  console.log(video.get());
}

var annotations = [];

function annotBrush() {
  console.log("adding brush to annotations");
  var annotName = $("#labelName").val();
  annotations.push([annotName, brush.extent()[0].getTime(), brush.extent()[1].getTime()]);
  console.log(annotations);
}

function updateAnnotationText() {
  var annotationText = "";
  for (var i = 0; i < annotations.length; ++i) {
    annotationText = annotationText.concat(annotations[i].join(",").concat("\n"));
  }
	console.log(annotationText);
  $("#annotationText").val(annotationText);
}

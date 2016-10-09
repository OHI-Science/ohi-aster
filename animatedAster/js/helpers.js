// get tooltip text
function getToolTipText(THIS) {
   // get data bound in d3.js via jQuery
   var dd = $(THIS).prop("__data__").data;
   
   var tooltipText = '<table border = 1>' +
	  '<tr><td>region:</td><td>' + dd.region  + '</td></tr>' +
	  '<tr><td>dataSet:</td><td>'  + dd.dataSet  + '</td></tr>' +
	  '<tr><td>count:</td><td>'  + dd.count  + '</td></tr>' +
	  '<tr><td>height:</td><td>' + dd.height  + '</td></tr>' +
	'</table>';
	
   return tooltipText;
}

// text label helper
function centroid(innerR, outerR, startAngle, endAngle){
	var r = text_offset * (innerR + outerR) / 2, a = (startAngle + endAngle) / 2 - (Math.PI / 2);
	return [ Math.cos(a) * r, Math.sin(a) * r ];
}
	  
function key(d) {
  return d.data.region;
}

function type(d) {
  d.count = +d.count;
  return d;
}

function findNeighborArc(i, data0, data1, key) {
  console.log("findNeighborArc");
  var d;
  return (d = findPreceding(i, data0, data1, key)) ? {startAngle: d.endAngle, endAngle: d.endAngle}
      : (d = findFollowing(i, data0, data1, key)) ? {startAngle: d.startAngle, endAngle: d.startAngle}
      : null;
}

// Find the element in data0 that joins the highest preceding element in data1.
function findPreceding(i, data0, data1, key) {
  console.log("findPreceding");
  var m = data0.length;
  while (--i >= 0) {
    var k = key(data1[i]);
    for (var j = 0; j < m; ++j) {
      if (key(data0[j]) === k){ return data0[j];}
    }
  }
}

// Find the element in data0 that joins the lowest following element in data1.
function findFollowing(i, data0, data1, key) {
  console.log("findFollowing");
  var n = data1.length, m = data0.length;
  while (++i < n) {
    var k = key(data1[i]);
    for (var j = 0; j < m; ++j) {
      if (key(data0[j]) === k){ return data0[j];}
    }
  }
}

function arcTween(d) {
  console.log("arcTween");
  var i = d3.interpolate(this._current, d);
  this._current = i(0);
  return function(t) { return arc(i(t)); };
}
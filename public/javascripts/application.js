// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

Report = {
  makeBar: function(container, data, labels) {
	function markerFomatter(obj) {
	  return obj.y;
	}
	
	var markers = {
		data:data, 
		markers:{show: true, position: 'ct', labelFormatter: markerFomatter}, 
		bars:{show: false}
	};
	
	var mapped = [];
	var len = data.length;
	var highest = 0;
	for (var i=0; i<len; i++)
	{
		if (highest < data[i])
		  highest = data[i];
		mapped.push({
			label: labels[i],
			data: [[i*0.25, data[i]]]
		});
	}
	
	mapped.push({label:"", data: [[len*0.25], 1]})
	
	Flotr.draw(
			$(container),
			mapped,
			{
				grid: {background: null},
	            bars: {show:true, barWidth:0.25, fillOpacity:1.0},
	            mouse: {track:true, relative:true},
				legend: {noColumns: 2},
				xaxis: {noTicks:0},
			    yaxis: {min: 0, autoscaleMargin: 1, max:highest*1.5}
			}
		);
  }	
};
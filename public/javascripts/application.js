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

Timer = {
	instances: null,
	
	init: function() {
		this.instances = new Hash();
		setInterval(Timer.tick, 1000);
	},
	
	register: function(id) {
		var el = $('entry_' + id);
		var time = el.down('.entryTime');
		var start = time.readAttribute('start_date');
		this.instances.set(id, [time, Date.parse(start)]);
	},
	
	restart: function(id) {
		this.remove(id);
		this.register(id);
	},
	
	remove: function(id) {
		var inst = this.instances.get(id);
		if (inst) {
			inst[0] = null;
			inst[1] = null;
			
			this.instances.unset(id);
		}
	},
	
	tick: function() {
		var now = Date.now();
		Timer.instances.values().forEach(function(inst) {
			var delta_s = (now - inst[1]) / 1000;
			var delta_m = delta_s / 60.0;
			var delta_h = Math.floor(delta_m / 60.0);
			
			delta_m = Math.floor(delta_m - (delta_h * 60.0));
			
			var delta_desc = "";
			if (delta_h < 1.0) {
				if (delta_m < 1.0)
					delta_desc = delta_s + "S";
				else
					delta_desc = delta_m + "M";
			} else {
				delta_desc = delta_h + "H" + delta_m + "M";
			}
			inst[0].innerHTML = delta_desc;
		});
	}
};
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

// source: http://anentropic.wordpress.com/2009/06/25/javascript-iso8601-parser-and-pretty-dates/
function parseISO8601(str) {
 // we assume str is a UTC date ending in 'Z'

 var parts = str.split('T'),
 dateParts = parts[0].split('-'),
 timeParts = parts[1].split('Z'),
 timeSubParts = timeParts[0].split(':'),
 timeSecParts = timeSubParts[2].split('.'),
 timeHours = Number(timeSubParts[0]),
 _date = new Date;

 _date.setUTCFullYear(Number(dateParts[0]));
 _date.setUTCMonth(Number(dateParts[1])-1);
 _date.setUTCDate(Number(dateParts[2]));
 _date.setUTCHours(Number(timeHours));
 _date.setUTCMinutes(Number(timeSubParts[1]));
 _date.setUTCSeconds(Number(timeSecParts[0]));
 if (timeSecParts[1]) _date.setUTCMilliseconds(Number(timeSecParts[1]));

 // by using setUTC methods the date has already been converted to local time(?)
 return _date;
}


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
		var start_ms = parseISO8601(start).getTime();
		this.instances.set(id, [time, start_ms]);//Date.parse(start)]);
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
			var delta_s = Math.floor((now - inst[1]) / 1000);
			var delta_desc = Timer.friendlyTime(delta_s);
			inst[0].innerHTML = delta_desc;
		});
	},
	
	updateDate: function(date_s) {
		var header = $('header_' + date_s);
		if (header) {
			var cur = header.next();
			var sum = 0;
			while (cur) {
				if (!cur.hasClassName('entry'))
					break;
				
				var time = parseInt(cur.readAttribute('times'));
				sum += time;
				cur = cur.next();
			}
			
			var span = header.down('span');
			if (span) {
				span.innerHTML = Timer.friendlyTime(sum);
			}
		}
	},
	
	friendlyTime: function(seconds) {
		var minutes = seconds / 60.0;
		var hours = minutes / 60.0;
		hours = Math.floor(hours);
		var minutes = Math.floor(minutes - (hours * 60.0));
		
		if (hours < 1.0) {
			if (minutes < 1)
				return seconds + "S";
			else
				return minutes + "M";
		} else {
			return hours + "H" + minutes + "M";
		}
	}
};

var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/spheriboarddev21');

var Point = new mongoose.Schema({
    x: Number,
    y: Number
});

var Drawing = mongoose.model('drawing', new mongoose.Schema({
	channel  :  String,
	owner  :  String,
	points  :  [Point],
	color : { type: Number, default: 0 }
}));

clients = {};

var io = require('socket.io').listen(42069, {log: true});
io.sockets.on('connection', function (socket) {
	socket.on('subscribe', function(data){
		socket.join(data.channel);
		socket['session'] = {'uid': data.uid,  // Unique identifier for client.
							 'did': mongoose.Types.ObjectId("000000000000"),
							 'channel': data.channel};  // Last drawing ID sent to client.
		clients[socket.id] = socket;
		socket.getdrawings(data, true);
	});

	socket.on('savedrawing', function(data){
		console.log('save called!');
		var drawing = new Drawing({'channel': socket['session'].channel, 
								   'owner': socket.session['uid'], 
								   'points': data.points,
								   'color': parseInt(data.color)});

		drawing.save(function (err) {
		  if (err) {
		  	console.log('error saving drawing: ' + err);
		  }
			for (client in clients) {
					console.log('updating client ' + client);
					clients[client].getdrawings(data, false);
			}
		});


	});
	 
	socket.on('disconnect', function(topic){
		socket.leave(topic);
		delete clients[socket.id];
	});

	socket.on('erasedrawing', function(topic){
		sel = { 'channel': socket['session'].channel };
		Drawing.find(sel).remove().exec(function(err, msg) {
			if (err) { return console.error('ERROR: ' + err); }
			console.log('deleted drawings for ' + socket['session'].channel);
		});
		for (client in clients) {
			clients[client].emit('drawingerased', {'channel': socket['session'].channel });
		}
	});

	socket.getdrawings = function(data, loopback) {
		console.log('triggered: ' + socket['session'].did + ' in ' + socket['session'].channel);
		sel = { 'channel': socket['session'].channel, '_id': { $gt: socket['session'].did } };
		if (!loopback) {
			sel = { 'channel': socket['session'].channel, '_id': { $gt: socket['session'].did }, 'owner' : { $ne : socket['session'].uid } };
			console.log('(loopback)');
		}
		if (socket['session'].uid == 'download') {
			delete sel['_id'];
		}
		Drawing.find(sel).exec(function(err, drawings) {
  			if (err) { return console.error('ERROR: ' + err) }
  			if (drawings.length <= 0) {
  				console.log('no drawings');
  				return
  			}
  			for (i=0; i < drawings.length; i++) {
  				points = [];
  				for (j=0; j < drawings[i].points.length; j++) {
  					points.push({x: drawings[i].points[j].x,
  								 y: drawings[i].points[j].y});
  				}
	  			socket.emit('drawing', {'points': points, 'color': drawings[i].color});
  				console.log(points);
  			}
  			if (drawings.length > 0)
	  			socket['session'].did = drawings[drawings.length - 1]['_id'];
	  		socket.emit('xferdone', {numdrawings: drawings.length});
		});
	};
});





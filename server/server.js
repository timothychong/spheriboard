var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/spheriboarddev14');

var Point = new mongoose.Schema({
    x: Number,
    y: Number
});

var Drawing = mongoose.model('drawing', new mongoose.Schema({
	channel  :  String,
	owner  :  String,
	points  :  [Point]
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
								   'points': data.points});

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

	socket.getdrawings = function(data, loopback) {
		console.log('triggered: ' + socket['session'].did);
		sel = { 'channel': socket['session'].channel, '_id': { $gt: socket['session'].did } };
		if (!loopback) {
			sel = { 'channel': socket['session'].channel, '_id': { $gt: socket['session'].did }, 'owner' : { $ne : socket['session'].uid } };
			console.log('(loopback)');
		}
		Drawing.find(sel).exec(function(err, drawings) {
  			if (err) { return console.error('ERROR: ' + err) }
  			if (drawings.length < 0)
  				return
  			for (i=0; i < drawings.length; i++) {
  				points = [];
  				for (j=0; j < drawings[i].points.length; j++) {
  					points.push({x: drawings[i].points[j].x,
  								 y: drawings[i].points[j].y});
  				}
	  			socket.emit('drawing', {'points': points});
  				console.log(points);
  			}
  			if (drawings.length > 0)
	  			socket['session'].did = drawings[drawings.length - 1]['_id'];
		});
	};
});





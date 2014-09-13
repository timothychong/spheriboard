var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/spheriboard');

var Coord = new Schema({
	x  : Number,
		y  : Number
});

var Segment = new Schema({
	s: Coord,
	e: Coord
});

var Drawing = mongoose.model('drawing', new Schema({
	channel  :  String,
	owner  :  String,
	segs  :  [Segment]
}));

var io = require('socket.io').listen(42069, {log: true});
io.sockets.on('connection', function (socket) {
	socket.on('subscribe', function(data){
		socket.join(data.channel);
		socket['uid'] = data.uid;
	});

	socket.on('savedrawing', function(data){
		//socket.broadcast.to(data.channel).emit(data);

		var drawing = new Drawing({'channel': data.channel, 'owner': socket.uid, 'segs': data.segs});

		drawing.save(function (err) {
		  if (err) {
		  	console.log('error saving drawing: ' + err);
		  }
		  console.log('saved drawing');
		});
	});
	 
	socket.on('disconnect', function(topic){
		socket.leave(topic);
	});

	socket.on('getdrawings', function(data){
		Drawing.find({ channel: data.channel }).exec(function(err, drawings) {
  			if (err) return console.log(err);
  			console.log(drawings);
		});
	});
});





////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																											  //
//								DIGITAL METAMORPHOSIS DESTRUCTION / CREATION								  //
//																											  //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// TODO: Break infinite loop when no available samples can be found

// Doesn't count recursions correctly, find out why!
// Unless I can make it work, I cannot stop recursion when it 
// reaches final destination. Then I cannot halt recursion and 
// make files transistion back to origin.
s.makeGui;
s.boot;
s.memSize = 8192 * 16;
(
var numChange = 250000;
var path;
var file;
var origin;
var destin;
var buf0;
var buf1;
var data;
var originRaw;
var destinRaw;
var rand = 0;


~findValidSample = {|start, goal, x = 0|
	var rand = rrand(0, start.size);
	if (x == rand && start[rand] == goal[rand]) {
		thisFunction.value(start, goal, rand);
	} {
		start[rand] = goal[rand];
	}; 
};

path = File.getcwd;

2.do{ |n| // create temp files since process is destructive
	file = SoundFile.new;
	file.openRead(path +/+ "drone" ++ n ++ ".wav");
	// is .alloc here necessary?
	buf0 = Buffer.alloc(s, file.numFrames, 2, bufnum: 0);
	data = FloatArray.newClear(file.numFrames * 2);
	originRaw = FloatArray.newClear(file.numFrames * 2);
	destinRaw = FloatArray.newClear(file.numFrames * 2);
	file.readData(data);
	file = SoundFile.new.headerFormat_("WAVE").sampleFormat_("int24").numChannels_(2);
	file.openWrite(path +/+ "drone" ++ n ++ "_temp.wav");
	file.writeData(data);
	file.close;
};

fork{
	var size = originRaw.size;
	var alter = 0;
	var epoch = 0;
	var recSum = 0;
	var iter = 0;
	
	// Load destination file into FloatArray
	destin = SoundFile.openRead(path +/+ "drone1_temp.wav");
	if(destin.notNil, {
		destin.readData(destinRaw);
	});
	
	// Load origin file into FloatArray
	origin = SoundFile.openRead(path +/+ "drone0_temp.wav");
	if(origin.notNil, {
		origin.readData(originRaw);
	});

	{ReplaceOut.ar(0, NHHall.ar(In.ar(0, 2)))}.play;

	loop{	
		s.sync;
		if(alter == 0, { // Use 2 alternating buffers
			buf0.free;
			buf0 = Buffer.loadCollection(s, originRaw, 2);
			alter = 1;
			{PlayBuf.ar(2, buf0, 0.5) * 0.3}.play;
		}, {
			buf1.free;
			buf1 = Buffer.loadCollection(s, originRaw, 2);
			alter = 0;
			{PlayBuf.ar(2, buf1, 0.5) * 0.3}.play;
		});
		35.wait;
		epoch = epoch + 1;
		format("EPOCH %\n", epoch).postln;

		numChange.do({ |item, i| // Do transition
			~findValidSample.value(originRaw, destinRaw);
			recSum = iter;

			iter = 0; // reset recursion counter
		});
		format("Number of recursion: %\n \n", recSum).postln;
		
		// origin = SoundFile.new.headerFormat_("WAVE").sampleFormat_("int24").numChannels_(2);
		// origin.openWrite(path +/+ "drone0_temp.wav");
		// origin.writeData(originRaw);
		// origin.close;
	}
};
)


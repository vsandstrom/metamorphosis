
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																											  //
//								DIGITAL METAMORPHOSIS DESTRUCTION / CREATION								  //
//																											  //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// TODO: Break infinite loop when no available samples can be found

s.boot;
s.memSize = 8192 * 16;
(
var numChange = 25000;
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

	loop{	
		s.sync;
		if(iter == 0, { // Use 2 alternating buffers
			buf0.free;
			buf0 = Buffer.loadCollection(s, originRaw, 2);
			iter = 1;
			{PlayBuf.ar(2, buf0, 0.5) * 0.3}.play;
		}, {
			buf1.free;
			buf1 = Buffer.loadCollection(s, originRaw, 2);
			iter = 0;
			{PlayBuf.ar(2, buf1, 0.5) * 0.3}.play;
		});
		30.wait;

		numChange.do({ |item, i| // Do transition
			rand = rrand(0, originRaw.size);
			if (originRaw[rand] == destinRaw[rand], {
				thisFunction.value(); // if origin and destination sample is same, 
									  // recursively find another that is not.
			}, {
				originRaw[rand] = destinRaw[rand];
			}
		);
		});
		
		// origin = SoundFile.new.headerFormat_("WAVE").sampleFormat_("int24").numChannels_(2);
		// origin.openWrite(path +/+ "drone0_temp.wav");
		// origin.writeData(originRaw);
		// origin.close;
	}
};
)

{ReplaceOut.ar(0, NHHall.ar(In.ar(0, 2)) * 0.15)}.play;

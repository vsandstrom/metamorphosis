s.boot;
Server.killAll;
(

// TODO: catch recursion if it gets out of hand
var path;
var file;
var data;
var buf;
var raw;
var rand = 0;
var size = 0;
var count = 0;

path = "/Users/viktorsandstrom/Downloads/TRUMLOOPAR\ LÅT\ 1.1/";


file = SoundFile.new;
file.openRead( path ++ "KOMP\ 4.wav" );
data = FloatArray.newClear(file.numFrames);
file.readData(data);
buf = Buffer.alloc(s, file.numFrames, 2, bufnum: 0);
file = SoundFile.new.headerFormat_("WAVE").sampleFormat_("int24").numChannels_(2);
file = SoundFile.openWrite(path ++ "KOMP\ 4_temp.wav");
file.writeData(data);
file.close;
fork {
	loop {
	file = SoundFile.openRead(path ++ "KOMP\ 4_temp.wav");
	raw = FloatArray.newClear(file.numFrames);
	file.readData(raw);

	buf = Buffer.sendCollection(s, raw, 2);
	s.sync;
	
Buffer.read(s, "/Users/viktorsandstrom/Documents/DAW/SC/MFsampler/samples/piano1.wav");
	{LeakDC.ar(PlayBuf.ar( 2, buf, 0.76))}.play;
	s.sync;


	100.do({ // Adds 100 new 0
		rand = rrand(0, raw.size-1);

		if (raw[rand] == 0.0) {
			
			count = count + 1;
			count.postln;
			thisFunction.value();
		}{
			raw[rand] = 0.0;
		};

		// if (raw[rand] == 0.0, {
		// 	raw[ [ rrand(0, rand -1), rrand(rand + 1, raw.size-1) ].choose ] = 0.0;
		// }, {
		// 	raw[rand] = 0.0;
		// });
	});
	file = SoundFile.new.headerFormat_("WAVE").sampleFormat_("int24").numChannels_(2);
	file = SoundFile.openWrite("/Users/viktorsandstrom/Downloads/TRUMLOOPAR\ LÅT\ 1.1/KOMP\ 4_temp.wav");
	// if(file.notNil, {
	// 	file.writeData(raw);
	// 	f.close;
	// }, {
	// 	"Failed to open %".format(file.path).warn;
	// });
	file.writeData(raw);
	file.close;
	

	}
};
)

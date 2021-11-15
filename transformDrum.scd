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
var numChange = 300;
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

path = "/Users/viktorsandstrom/Downloads/TRUMLOOPAR\ LÅT\ 1.1/";

~findValidSample = {|start, goal, chunk, x = 0|
	var rand = rrand(0, start.size);
	var i = 0;
	if (x == rand && start[rand] == goal[rand]) {
		thisFunction.value(start, goal, chunk, rand);
	} {
		for(0, chunk, {|i|
			start.wrapPut((rand + i), goal.wrapAt((rand + i)));
		});
	
	}; 
};

// b = Buffer.read(s, (path ++ "KOMP\ 4.wav").asString);
file = SoundFile.new;
file.openRead(path ++ "KOMP\ 4.wav");
// For stereofiles, numFrames has to be doubled, a Frame contains sample of both L and R signals.
// Easiest is to query the SoundFiles instance method .numChannels.
origin = FloatArray.newClear(file.numFrames*file.numChannels);
file.readData(origin);
// variable overloading - Be careful
origin = Buffer.loadCollection(s, origin, 2);

{PlayBuf.ar(2,b,1,1,0,0,2) * 0.2}.play;


);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																											  //
//								DIGITAL METAMORPHOSIS DESTRUCTION / CREATION								  //
//																											  //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

									// **** DRUM REPLACEMENT/SCRAMBLE **** // 

/*
		Since function allows for wrap around the arrays first and last index, it will never do complete transform
		It will continue to transform the array until it somehow returns to origin, how I do not know
*/



// TODO: Break infinite loop when no available samples can be found

// Doesn't count recursions correctly, find out why!
// Unless I can make it work, I cannot stop recursion when it 
// reaches final destination. Then I cannot halt recursion and 
// make files transistion back to origin.
s.makeGui;
s.boot;
s.memSize = 8192 * 16;

Server.killAll;

(
var numChange = 300;
var path;
var file0;
var file1;
var origin;
var destin;
var buf0;
var buf1;
var data;
var originBuf;
var destinBuf;
var rand = 0;

path = "/Users/viktorsandstrom/Downloads/TRUMLOOPAR\ LÅT\ 1.1/";

~findWrapSample = {|start, goal, chunk, x = 0|
	var rand = rrand(0, start.size);
	var i = 0;
	if (x == rand) {
		thisFunction.value(start, goal, chunk, rand);
	} {
		for(0, chunk, {|i|
			start.wrapPut((rand + i), goal.wrapAt((rand + i)));
		});
	
	}; 
};

// For stereofiles, numFrames has to be doubled, a Frame contains sample of both L and R signals.
// Easiest is to query the SoundFiles instance method .numChannels.

// StartPoint-file
file0 = SoundFile.new;
file0.openRead(path ++ "KOMP\ 4.wav");
origin = FloatArray.newClear(file0.numFrames*file0.numChannels);
file0.readData(origin);
// variable overloading - Be careful
originBuf = Buffer.loadCollection(s, origin, 2);

// EndPoint-file
file1 = SoundFile.new;
file1.openRead(path ++ "KOMP\ 3.wav");
destin = FloatArray.newClear(file1.numFrames*file1.numChannels);
file1.readData(destin);
// variable overloading - Be careful
destinBuf = Buffer.loadCollection(s, destin, 2);

fork{
	loop{
		{PlayBuf.ar(2, destinBuf, doneAction: 2) * 0.3}.play;
		100.do{
			~findWrapSample.value(destin, origin, 100);
		};
		wait(destin.size / 48000 / 2);
		destinBuf = Buffer.loadCollection(s, destin, 2);
	}
}
);


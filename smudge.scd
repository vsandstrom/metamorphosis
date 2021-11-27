/* 
				Change a chunk of samples if a peak is detected. Measure the length of peak and repeat
				exactly behind it. ( added artificial trailing samples for smoother sound )

*/

s.waitForBoot({



var buf, array, chunk, file, path;
var max = 1.0;
var padding = 150;


// path = "/Users/viktorsandstrom/Downloads/TRUMLOOPAR\ LÅT\ 1.1/KOMP\ 3.wav";


path = "/Users/viktorsandstrom/Documents/DAW/SC/Sjukhusinnergård/LillJanSkogen5.WAV";


//////////////////// Setup of soundfile and transformation into supercollider float array. ////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

file = SoundFile.new;

file.openRead(path);

array = FloatArray.newClear(file.numChannels*file.numFrames);

file.readData(array);

buf = Buffer.loadCollection(s, array, file.numChannels);

s.sync;
buf.plot; 


/*

Smudge - look at the absolute value of each entry in the FloatArray representing the audio file. 
If some value moves past the threshold, it gets sampled and stored in a shorter array, which starts
to write to the section immediately after the section just sampled, creating a stutter-effect. 
This stutter chunk is only determined by the the amplitude of the sample. 

After each iteration something should happen with the threshold range, to introduce new stutterings. 
Should drop from maximum range (or just above the maximum value in array), so that the effect is 
not so pronounced at the beginning. 

Should I add some delayed responce, so that it could be more pronounced chunks, since it now sounds like the other
destruction loop-drum patch.

*/


	fork{
		chunk = Array.new;
		s.sync;

		loop{

			{PlayBuf.ar(2, buf, 1, 1, 0, 0, doneAction: 2)}.play;

			((file.numFrames / 48000) / 2).wait;

			for (0, (array.size - 1)) { |i|
				var temp = array[i];

				if (temp.abs >= max || padding != 0) { // if above threshold, add to chunk-array
					chunk.add(temp);
					if (temp.abs < max) {
						padding = padding - 1;
					}

				}{
					if(chunk.size != 0){ // Whenever it is not bigger than temp, reintroduce chunk
						padding = 150;
						for(0, (chunk.size-1)){ |j|
						array.wrapPut((i + j), chunk.removeAt(0)); // chunk is FIFO

					
						};
					};
					

				};
			};

			buf = Buffer.loadCollection(s, array, file.numChannels);
			((file.numFrames / 48000) / 2).wait;
			max = max * 0.9535;
			max.postln;
		};
	};
});


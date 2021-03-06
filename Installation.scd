

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																										   //
//												METAMORPHOSIS											   //
//																										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

NetAddr.langPort; // Port: 57120


s.boot;
s.waitForBoot({
	// SETUP
	var numChanges = 0;
	var count = 0;
	var path, dirs;
	var files, data;
	var syn0, syn1;
	var play;
	var win, text0, text1, num0, num1, button0, button1, slider0, slider1;

	~slider0 = 0;
	~slider1 = 0;
	~button = 0;
	~buttonSmudge = 0;

	// SUPERCOLLIDER DOES *NOT* INLCUDE [sclang <***.scd>] IN ITS "ARGC" COUNT
	~argv = thisProcess.argv;
	Post << ~argv << Char.nl;
	// Path to folder where the audio files are:
	if (~argv.size < 1) {
		path = PathName(thisProcess.nowExecutingPath).pathOnly;
		path = path +/+ "Samples";
	}{
		if( ~argv.size == 1 ){
			path = ~argv[0];
		}
		{
			thisProcess.shutdown;
			0.exit;
		}
	};

	// path = "~/Documents/DAW/SC/Installation/Samples";
	
	// functions
	~smudge = {|array, max|
		var padding = 150;
		var chunk = Array.new;
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
	};

	~metamorphosis = {|larv, fjril, chunk, x = -1|
		var rand = rrand(0, larv.size);
		var i = 0;
		if (x == rand && larv[rand] == fjril[rand]) {
			thisFunction.value(larv, fjril, chunk, rand);
		} {
			for(0, chunk, {|i|
				larv.wrapPut((rand + i), fjril.wrapAt((rand + i)));
			});
		};
	};
	// {NHHall.ar(In.ar(0, 2), 4)}.play;

	// housekeeping after restart
	Buffer.freeAll;

	s.sync;

	// load soundfiles into arrays
	dirs = PathName.new(path).entries;
	files = Array.new(dirs.size);

	for (0, dirs.size - 1) { |i|
		var arr;
		var percent = 100 / dirs.size;
		data = SoundFile.new;

		// open file - .fullPath is needed to get the string and not the PathName object
		data.openRead(dirs[i].fullPath);
		("Loading... " ++ (percent * (i+1)).asString ++ " %").postln;
		if (data.notNil){
			// add arrays to one array, easier for random sourcing.
			arr = FloatArray.newClear(( data.numFrames*data.numChannels ));
			data.readData(arr);
			arr.normalize(-1, 1);
			s.sync;
			files.add(arr);
		}{
			Error("File could not be read").throw;
		};

		data.close; // close file
	};


	// LOOP
	play = Routine.new({
		var file;
		var buf0, buf1;
		var source, sourceArray;
		var innerFiles;
		var check = true;
		var max = 1.0;
		var numC = 2;


		// Fetch fresh copy after reset
		innerFiles = files.deepCopy;
		s.sync;
		source = innerFiles.removeAt(rrand(0, files.size - 1));
		2.wait;

		loop{

			// EPOCH postln;
			count = count + 1;
			("EPOCH %".format(count)).postln;


			// choose which file to "borrow from" on random
			file = files[rrand(0, files.size - 1)];
			if (max <= 0){
				max = 1.0;
			}{
				max = max - 0.2;
			};

			// PLAYING HERE
			if (check == true) { // alternate between different buffers
				check = false;
				buf0 = Buffer.loadCollection(s, source, 2);
				s.sync;
				syn0 = {PlayBuf.ar(2, buf0, 1, doneAction: 2)}.play;
				numC = buf0.numChannels
				(((source.size / s.sampleRate) / 2)* 0.9).wait;

			}{
				check = true;
				buf1 = Buffer.loadCollection(s, source, 2);
				s.sync;
				syn1 = {PlayBuf.ar(2, buf1, 1, doneAction: 2)}.play;
				numC = buf1.numChannels
				(((source.size / s.sampleRate) / 2)* 0.9).wait;
				// ((source.size / 48000) / 4).wait;
			};


			// DO TRANSFORMATION HERE
					// array manipulation

			// smudge before adding new chunks? gives "clarity" to new chunks introduced
			if(~buttonSmudge > 0.5) {
				~smudge.value(source, max);
			};


			// METAMORPHOSIS

			numChanges.do{
				~metamorphosis.value(source, file, ~chunk);
			};

			(((source.size / s.sampleRate) / 2)* 0.9).wait;

			// INTERACTIVITY

				// dynamically control how big the chunks are (x.do)
			numChanges = ~slider0.linlin(0.0, 1.0, 0, 250).ceil;
			~chunk = ~slider1.linlin(0.0, 1.0, 0, 15000).ceil;
		}.yield;
	});

	play.play;

	fork{
		loop{	// if reset button has been pressed => reset Routine
			if (~button > 0.5)
			{play.stop; play.reset; Buffer.freeAll; syn0.free; syn1.free; 1.wait; "Reset!".postln;
			}{
				// wait for the reset and buffers clearing before playing again
				if (play.isPlaying == false)
				{count = 0; 3.wait;play.next; "Playing".postln;}
			};
			0.1.wait;
		};
	};

	// Window GUI

	(
		win = Window("gui", Rect(800, 300, 300, 270));

		// Number of changes in source file
		text0 = StaticText(win, Rect(20, 10, 80, 20))
			.string_("Changes");
		num0 = NumberBox(win, Rect(20, 35, 50, 20));
		slider0 = Slider(win, Rect(30, 60, 30, 180))
			.action_({|slider|
				var val;
				~slider0 = slider.value;
				val = slider.value.linlin(0.0, 1.0, 0, 250).ceil;
				num0.value_(val);
			}
		);

		// The size of the "change" (in samples)
		// t = TextField(win, Rect(50, 50))
		// 	.string_("Size");
		text1 = StaticText(win, Rect(100, 10, 80, 20))
			.string_("Size");
		num1 = NumberBox(win, Rect(100, 35, 50, 20));
		slider1 = Slider(win, Rect(110, 60, 30, 180))
			.action_({|slider|
				var val;
				~slider1 = slider.value;
				val = slider.value.linlin(0.0, 1.0, 0, 15000).ceil;
				num1.value_(val);
			}
		);

		// Reset button
		button0 = Button(win, Rect(180, 60, 100, 50))
			.states_([
				["Stop&Reset", Color.red, Color.black],
				["Restart", Color.white, Color.blue]
			])
			.action_({arg button;
				~button = button.value;
			}
		);
		button1 = Button(win, Rect(180, 160, 100, 50))
			.states_([
				["SmudgeOn", Color.black, Color.white],
				["SmudgeOff", Color.black, Color.grey]
			])
			.action_({arg button;
				~buttonSmudge = button.value;
			}
		);
		win.front;
		CmdPeriod.add({win.close});
	);

	// Remote Control from web application via Open Sound Control

	(
		o = OSCFunc.new({|msg, time, addr, receivePort|
			~button = msg[1];
		}, '/reset');

		p = OSCFunc.new({|msg, time, addr, receivePort|
			~buttonSmudge = msg[1];
			if (~buttonSmudge > 0) {
				Post << "smudge On" << $\n;
			}{
				Post << "smudge Off" << $\n;
			};
		}, '/smudge');

		q = OSCFunc.new({|msg, time, addr, receivePort|
			~slider0 = msg[1];
			Post << "Number of windows: " << ~slider0 << Char.nl;
		}, '/slider0');

		r = OSCFunc.new({|msg, time, addr, receivePort|
			~slider1 = msg[1];
			Post << "Size of window: " << ~slider1 << Char.nl;
		}, '/slider1');
	);
});


Buffer.freeAll;
s.boot;

s.waitForBoot({
	var file;
	var nameNum;
	var path;
	var buf = Buffer.alloc(s, s.sampleRate * 60, 2);

	SynthDef(\drone, {
		var sig, env;
		env = EnvGen.kr(Env.new([0,1,0],[10, 25], [-4,4]), \t_trig.kr(1));
		sig = DWGBowedTor.ar(
			\freq.kr(300),
			\velb.kr(0.5),
			\force.kr(1),
			\t_trig.kr,
			\pos.kr(0.14),
			\release.kr(25),
			\c1.kr(1),
			\c3.kr(3),
			\impZ.kr(0.55),
			\mistune.kr(8.5),
			\c1tor.kr(2.3),
			\c3tor.kr(300),
			\iZtor.kr(1.8));

		sig = DWGSoundBoard.ar(sig);

		Out.ar(0, sig!2 * env * 0.3);
	}).add;

	SynthDef(\rec, {
		var in, rec;

		in = In.ar(0, 2);
		rec = RecordBuf.ar(in, buf, trigger: 1, doneAction:2);
	}).add;

	s.sync;


	// Synth(\rec);
	// nameNum = 0;
	// Synth(\drone, [\freq, 1* 300]);
	// Synth(\drone, [\freq, 6/5* 300]);
	// Synth(\drone, [\freq, 5/3* 300]);
	
	Synth(\rec);
	nameNum = 1;
	Synth(\drone, [\freq, 2/3* 300]);
	Synth(\drone, [\freq, 6.5/5* 300]);
	Synth(\drone, [\freq, 7/9* 300]);

	30.wait;
	
	path = (File.getcwd() +/+ "drone" ++ nameNum ++ ".wav");
	buf.write(path, "WAVE", "int24");

	


});

RecordBuf


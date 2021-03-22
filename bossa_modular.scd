s.boot;
s.quit;
c.free;
s.reboot

MIDIClient.init;
m = MIDIOut(2);

~sampleName = "bossa_loop_mono_102bpm.wav";
~sampleName = "bossa_loop_01.wav";
~sampleName = "511819__valentinsosnitskiy__acoustic-performanse-in-ableton-live.wav"
~sampleName = "400698__fullmetaljedi__rozenbaum-chords-bossa.wav";
~sampleName = "485969__kevp888__190921-0668-fr-batucada.wav";
~sampleName = "400698__fullmetaljedi__rozenbaum-chords-bossa.wav";

(
~path = PathName(thisProcess.nowExecutingPath).parentPath;
Buffer.freeAll(s);
~inputBuffer = Buffer.read(s, ~path ++ ~sampleName);
)


// Pitch ========================================================


(
~tempNN = 0;
~dn = 7;
SynthDef("pitchFollower", { |out, trigRate = 100, inputAmp = 0.5 |
	var inputBuf, pitchSig, freq, hasFreq, depth = 0.85, trig;
    inputBuf = PlayBuf.ar(2, ~inputBuffer, BufRateScale.kr(~inputBuffer), loop: 1);
    # freq, hasFreq = Pitch.kr(inputBuf, ampThreshold: 0.1, median: 1, minFreq: 50.0, maxFreq: 5000.0);
	freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
	trig = Impulse.ar(trigRate);
	SendReply.ar(trig, '/pitchFreq', freq);
	Out.ar(0, inputBuf*inputAmp);
}).add;
OSCdef(\pitchInfo, {|msg|
	var nn, vv, dt;
	nn = msg[3].cpsmidi.round;
	dt = rrand(0.001,0.05);
	vv = rrand(10,110);
	if (nn != ~tempNN,{
		m.noteOn(1,nn,vv);
		m.noteOn(2,nn+~dn,vv);
		{
			dt.wait;
			m.noteOff(1,nn);
			m.noteOff(2,nn+~dn);
			dt.wait;
		}.fork;
	~tempNN = nn;
	});
},'/pitchFreq');
)
~test = Synth.new(\pitchFollower, [\trigRate, 10]);
~test.free;



// DRAFT ========================================================

s.meter

(
MIDIClient.init;
MIDIClient.destinations;
MIDIClient.destinations[2].uid
)
MIDIClient.init;
m = MIDIOut(2);
m.connect(2)
m.noteOn(4,1,64);
m.noteOff(4,1,64);
m.allNotesOff(4);


(
Routine({
	(5,10..100).scramble.do{
	arg nn,vv,dt;
	dt = rrand(0.001,0.05);
	vv = rrand(10,110);
	m.noteOn(1,nn,vv);
	dt.wait;
	m.noteOff(1,nn);
	dt.wait;
}
}).play;
)

(
Pdef(\seq_MIDIout,
	Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 1,
	\midinote, Pexprand(10,127,inf),
	\amp, Pexprand(20,127,inf)/127,
	\sustain,0.05,
	\dur,Pexprand(0.25,0.25,inf),
);
);
)

Pdef(\seq_MIDIout).play;
Pdef(\seq_MIDIout).stop;
Pdef(\seq_MIDIout).set([\dur,0.5,\sustain,0.01]);
Pdef(\seq_MIDIout).set([\chan, 2]);

1/0.01

SynthDef.new(\getBusInfo,{
	arg trigRate = 1000;
	var sig, amp, trig, busses = [];
	amp = [];
	~numOfBusses.do{
		arg idx;
		sig = In.ar(~busArray[idx],1);
		amp = amp.add(Amplitude.ar(sig));
		busses = busses.add(sig);
	};
	trig = Impulse.ar(trigRate);
	SendReply.ar(trig, '/busAmp', amp);
	Out.ar(0,Splay.ar(busses,level:0.5));
}).add;




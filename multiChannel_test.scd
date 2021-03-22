s.boot;
s.meter;
s.quit;
s.plotTree;

/*
Channels of HDMI to analog converter
| FL | FR | SL | SR | CEN | SW | SBL | SBR |
|  0 |  1 |  6 |  7 |  2  |  3 |  4  |  5  |
*/
s.options.numAudioBusChannels;
s.options.numOutputBusChannels = 8;
s.reboot;

(
SynthDef.new(\multiChannelTest, {
	arg sig, trig, amp, freq, out = 0;
	sig = amp * SinOsc.ar(LFNoise0.kr(3).exprange(0.5*freq,3*freq).round);
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc,trig,doneAction: 2);
	Out.ar(out,sig);
}
).add;
)

{Out.ar(2,PinkNoise.ar(0.25))}.play;

(
SynthDef.new(\inputSound,{
	arg amp = 0.5, out = 1;
	var sig;
	sig = SoundIn.ar(0);
	Out.ar(out,sig*amp);
}).add;
)

y = Synth.new(\inputSound,[\out,[2]]);
y.free;

x = Synth.new(\multiChannelTest,[\freq, 356, \amp, 0.25, \out, 0]);
x = Synth.new(\multiChannelTest,[\freq, 356, \amp, 0.25]);
x.free;
s.freeAll;


(
Pdef(\multi_event,
		Pbind(
			\instrument, \inputSound,
		    \dur,Pseq(linrand(0.5!4),inf),
		    \out, Pseq([0, 3, 2, 1, 7, 6],inf),
			\freq, Pexprand(50,200,inf),
			//\pan, Pwhite(-0.8,0.8,inf),
		)
	);
)

Pdef(\multi_event).play;
Pdef(\multi_event).stop;
x.free;
s.freeAll;

//=======================================================================

x = {PinkNoise.ar([0,0,0,0.25,0,0,0,0])}.play;
x = {PinkNoise.ar([0.25,0.25,0.05,0.25,0.25,0.25])}.play;

//=======================================================================

(
SynthDef.new(\multiChannelTest_pureTone, {
	arg sig, amp=0.25, freq=200, out = 0, at = 0.01, re = 0.5;
	sig = amp * SinOsc.ar(freq);
	sig = sig * EnvGen.kr(Env.perc(at,re),doneAction:2);
	Out.ar(out,sig);
}
).add;
)
(
Pdef(\multi_event_pt,
		Pbind(
		\instrument, \multiChannelTest_pureTone,
		//\dur,Pseq([0.5, 1.5],inf),
		\dur,Pexprand(0.01,0.5,inf),
		\amp,Pexprand(0.25,0.5,inf),
		/*\amp,[Pexprand(0.1,0.25,inf),
			Pexprand(0.1,0.25,inf),
			Pexprand(0.1,0.25,inf),
			Pexprand(0.1,0.25,inf),
			0,
			0,
			Pexprand(0.1,0.25,inf),
			Pexprand(0.1,0.25,inf),
		],*/
		\at, Pexprand(0.01,0.1,inf),
		\re, Pexprand(0.05,1,inf),
		//\out,[Pexprand(-0.5,8,inf).round,Pexprand(-0.5,8,inf).round],
		//\out,[Pexprand(-0.5,8,inf).round
		\out, Pseq([0, 2, 3, 1, 7, 6],inf),
		\freq, Pexprand(50,800,inf),
		)
	);
)

Pdef(\multi_event_pt).play;
Pdef(\multi_event_pt).stop;


x = Synth.new(\multiChannelTest_pureTone,[\freq, 247, \amp, 0.25, \out, 0,\re, 1]);
s.freeAll;

//=======================================================================

(
SynthDef.new(\multiChannelTest_pureTonePan, {
	arg sig, amp=0.25, freq=200, out = 0, pan;
	pan = LFNoise0.kr(3).exprange(-1,1);
	sig = amp * SinOsc.ar(freq);
	sig = Pan2.ar(sig,pan,amp);
	Out.ar(out,sig);
}
).add;
)

x = Synth.new(\multiChannelTest_pureTonePan,[\freq, 250, \amp, 0.25, \out, 2]);
s.freeAll;


x = Synth.new(\multiChannelTest_pureTone,[\freq, 247, \amp, 0.25, \out, 2]);
s.freeAll;






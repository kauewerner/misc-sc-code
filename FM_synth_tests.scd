s.boot;
s.quit;
s.plotTree;
s.meter;
(
SynthDef.new(\FMtest, {
	arg freq_c1 = 110, atk_c1 = 0.01, rel_c1 = 1, amp_c1 = 0.1,
	    freq_c2 = 110, atk_c2 = 0.01, rel_c2 = 1, amp_c2 = 0.1,
	    freq_m1 = 220, atk_m1 = 0.01, rel_m1 = 1, amp_m1 = 0.1,
	    freq_m2 = 220, atk_m2 = 0.01, rel_m2 = 1, amp_m2 = 0.1,
	    pan = 0;
		var osc_c1, osc_c2, osc_m1, osc_m2,
	        env_c1, env_c2, env_m1, env_m2,
	        sig;

	    // modulator 1
	    env_m1 = EnvGen.kr(Env.perc(atk_m1,rel_m1),doneAction:2);
	    osc_m1 = SinOsc.kr(freq_m1,mul:amp_m1,add:amp_m1)*env_m1;

	    // modulator 2
	    env_m2 = EnvGen.kr(Env.perc(atk_m2,rel_m2),doneAction:2);
	    osc_m2 = SinOsc.kr(freq_m2*(1 + osc_m1))*env_m2;

	    // carrier 1
	    env_c1 = EnvGen.kr(Env.perc(atk_c1,rel_c1),doneAction:2);
	    osc_c1 = SinOsc.ar(freq_c1*(1 + osc_m2*amp_m2));

	    // carrier 2
	    env_c2 = EnvGen.kr(Env.perc(atk_c2,rel_c2),doneAction:2);
	    osc_c2 = SinOsc.ar(freq_c2*(1 + osc_m1*amp_m1));

	    // combination of modulator and carrier
	sig = (osc_c1 * env_c1 * amp_c1) + (osc_c2 * env_c2 * amp_c2);
	    sig = Pan2.ar(sig,pan * SinOsc.kr(0.1));
		Out.ar(0,sig);
}).add;
)

(
x = Synth.new(\FMtest,[
	\freq_c1,320,
	\atk_c1,0.01,
	\rel_c1, 4,
	\amp_c1,0.1,
	\freq_m1,440,
	\atk_m1,0.1,
	\rel_m1, 0.01,
	\amp_m1,0.5,
]);
)

(
Pbind(\instrument,\FMtest,
	\dur, Pseq([0.25, 0.125, 0.5, 0.125],inf),
	//\freq_c1, Pseq([220, 990 , 330, 880],inf),
	\freq_c1, Pexprand(220,1880,inf).round(3),
	\atk_c1,Pexprand(0.005,0.01,inf),
	\rel_c1, Pexprand(0.1,1.5,inf),
	\amp_c1,0.15,
	\freq_c2, Pexprand(220,1880,inf).round(3),
	\atk_c2,Pexprand(0.005,0.01,inf),
	\rel_c2, Pexprand(0.1,1.5,inf),
	\amp_c2,0.15,
	\freq_m1,Pexprand(55,250,inf).round(3),
	\atk_m1,Pexprand(0.001,0.01,inf),
	\rel_m1,Pexprand(3,6,inf),
	\amp_m1,Pwhite(0.5,0.9,inf),
	\freq_m2,Pexprand(255,5880,inf).round(3),
	\atk_m2,Pexprand(0.001,0.01,inf),
	\rel_m2,Pexprand(3,6,inf),
	\amp_m2,Pwhite(0.5,0.9,inf),
	\pan,Pwhite(-0.8,0.8,inf),
).play;
)
(
Pbind(\instrument,\FMtest,
	\dur, Pseq([2, 1, 3, 2],inf),
	//\freq_c1, Pseq([220, 990 , 330, 880],inf),
	\freq_c1, Pexprand(50,880,inf).round(3),
	\atk_c1,Pexprand(0.5,2,inf),
	\rel_c1, Pexprand(3,6,inf),
	\amp_c1,0.25,
	\freq_c2, Pexprand(50,880,inf).round(3),
	\atk_c2,Pexprand(0.005,0.01,inf),
	\rel_c2, Pexprand(3,6,inf),
	\amp_c2,0.25,
	\freq_m1,Pexprand(55,250,inf).round(3),
	\atk_m1,Pexprand(0.001,0.01,inf),
	\rel_m1,Pexprand(3,6,inf),
	\amp_m1,Pwhite(0.5,0.9,inf),
	\freq_m2,Pexprand(255,5880,inf).round(3),
	\atk_m2,Pexprand(0.001,0.01,inf),
	\rel_m2,Pexprand(3,6,inf),
	\amp_m2,Pwhite(0.5,0.9,inf),
	\pan,Pwhite(-0.8,0.8,inf),
).play;
)
(
Pbind(\instrument,\FMtest,
	\dur, Pseq([0.25, 1.75],inf),
	//\freq_c1, Pseq([220, 990 , 330, 880],inf),
	\freq_c1, Pexprand(150,200,inf).round(3),
	\atk_c1,Pexprand(0.005,0.01,inf),
	\rel_c1, Pexprand(0.5,1.5,inf),
	\amp_c1,0.3,
	\freq_c2, Pexprand(150,200,inf).round(3),
	\atk_c2,Pexprand(0.005,0.01,inf),
	\rel_c2, Pexprand(0.5,1.5,inf),
	\amp_c2,0.3,
	\freq_m1,Pexprand(55,155,inf).round(3),
	\atk_m1,Pexprand(0.001,0.01,inf),
	\rel_m1,Pexprand(3,6,inf),
	\amp_m1,Pwhite(0.5,0.9,inf),
	\freq_m2,Pexprand(255,5880,inf).round(3),
	\atk_m2,Pexprand(0.001,0.01,inf),
	\rel_m2,Pexprand(3,6,inf),
	\amp_m2,Pwhite(0.5,0.9,inf),
	\pan,0,
).play;
)
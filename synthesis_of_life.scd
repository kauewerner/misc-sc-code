(
s.waitForBoot{
var width = 1000, height = 700, resolution = 30;
var window, canvas;
var attack = 0.01, release = 0.1, amplitude = 0.125, jitter = 1, frameRate = 12, instrument = 'sine', waveShapes = ['sine','triangle','saw','square'], maxFreq = 8000, waveIdx = 0, frame = 0;
var playFlag = false, newFlag = false, flagStart = false, flagNanoKontrol2 = false;
var attackKnob, releaseKnob, jitterKnob, volumeKnob, pitchKnob, rateKnob, resolutionKnob, runButton, newButton, waveSelector, currentAttackKnobValue = 0.5,currentReleaseKnobValue = 0.5;
	var jitterRange = 60, attackRange = [0.001,0.15], releaseRange = [0.005,0.25], resolutionRange = [30,90], volumeRange = [0.0,0.25], pitchRange = [500,8000], rateRange = [0.25, 24];
var sum_neighbors, draw_grid, update_state, currentState;
if(flagNanoKontrol2,{n = NanoKontrol2()});
SynthDef.new('sine',{
	arg freq = 220, amp = 0.5, at = 0.001, re = 1, pan = 0;
	var sig, env;
	sig = SinOsc.ar(freq,mul:0.125);
	env = EnvGen.ar(Env.perc(at,re),doneAction:2);
	sig = Pan2.ar(sig*env*amp,pan);
	Out.ar(0,sig);
}).add;
SynthDef.new('triangle',{
	arg freq = 220, amp = 0.5, at = 0.001, re = 1, pan = 0;
	var sig, env;
	sig = LFTri.ar(freq,mul:0.125);
	env = EnvGen.ar(Env.perc(at,re),doneAction:2);
	sig = Pan2.ar(sig*env*amp,pan);
	Out.ar(0,sig);
}).add;
SynthDef.new('saw',{
	arg freq = 220, amp = 0.5, at = 0.001, re = 1, pan = 0;
	var sig, env;
	sig = Saw.ar(freq,mul:0.1);
	env = EnvGen.ar(Env.perc(at,re),doneAction:2);
	sig = Pan2.ar(sig*env*amp,pan);
	Out.ar(0,sig);
}).add;
SynthDef.new('square',{
	arg freq = 220, amp = 0.5, at = 0.001, re = 1, pan = 0;
	var sig, env;
	sig = Pulse.ar(freq,0.5,mul:0.1);
	env = EnvGen.ar(Env.perc(at,re),doneAction:2);
	sig = Pan2.ar(sig*env*amp,pan);
	Out.ar(0,sig);
}).add;
currentState = {{2.rand}!(height/resolution).asInteger}!(width/resolution).asInteger;
sum_neighbors = {|x, y, state|
	var sum = 0, xSize, ySize, tempX, tempY;
	xSize = state.size;
	ySize = state[0].size;
	(-1..1).do{|i|
		(-1..1).do{|j|
			tempX = (x + i + xSize) % xSize;
			tempY = (y + j + ySize) % ySize;
			sum = sum + state[tempX][tempY];
		};
	};
	sum = sum - state[x][y];
	sum
};
draw_grid = {|state, res|
	state.size.do{|i|
		state[0].size.do{|j|
			if(state[i][j] > 0,{
				Pen.fillColor_(Color.hsv(j/state[0].size,1-(jitter/jitterRange),0.5 + 0.25*((attack/(2*attackRange[1])) + (release/(2*releaseRange[1])))));
				Pen.fillRect(Rect(i*res,j*res,res,res));
			});
		};
	};
};
update_state = {|state|
	var next = {0!(height/resolution).asInteger}!(width/resolution).asInteger;
	state.size.do{|i|
		state[0].size.do{|j|
			var sum;
			sum = sum_neighbors.value(i,j,state);
			if( (state[i][j] == 0) && (sum == 3 ),{
				next[i][j] = 1;
				Synth.new(instrument,[
					// \freq, ((j+1)*60 + jitter.rand),
					\freq, (j.linexp(0,state[0].size-1,40,maxFreq).asInteger + jitter.rand),
					\amp, amplitude*0.25,
					\at, attack,
					\re, release,
					\pan, i.linlin(0,state.size-1,-1,1)]);
			}, {
				if ( (state[i][j] == 1) && ( (sum > 3 ) || (sum < 2) ) ,{
					next[i][j] = 0;
				},{
					next[i][j] = state[i][j];
				});
			} );
		};
	};
	next
};
Window.closeAll;
window = Window("SYNTHESIS OF LIFE",
	Rect(Window.screenBounds.width*0,
	Window.screenBounds.height*0.05,
	width, height)
);
window.background = Color.new(0.2,0.2,0.2,1.0);
canvas = UserView(window, Rect(0,0,width*0.7,height));
canvas.background = Color.white;
canvas.clearOnRefresh = true;
canvas.drawFunc = {
	Pen.color_(Color.black);
	Pen.strokeColor_(Color.black);
	draw_grid.value(currentState, resolution);
		// frameIdx = frameRate %
		if( (frame % ((rateRange[1]/frameRate).asInteger)) == 0,{
			if (flagStart,{
				currentState = update_state.value(currentState);
			});
		});
	frame = frame + 1;
};
StaticText(window,Rect(width*0.7125,height*0.0125,width*0.15,height*0.1))
.align_(\center)
.stringColor_(Color.white)
.string_("attack");
attackKnob = Knob(window,Rect(width*0.7375,height*0.1,width*0.1,height*0.1))
.value_(0.5)
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	currentAttackKnobValue = obj.value;
	attack = obj.value.linlin(0,1,attackRange[0],attackRange[1]);
});
StaticText(window,Rect(width*0.7125,height*0.2125,width*0.15,height*0.1))
.align_(\center)
.stringColor_(Color.white)
.string_("release");
releaseKnob = Knob(window,Rect(width*0.7375,height*0.3,width*0.1,height*0.1))
.value_(0.5)
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	currentReleaseKnobValue = obj.value;
	release = obj.value.linlin(0,1,releaseRange[0],releaseRange[1]);
});
StaticText(window,Rect(width*0.7125,height*0.4125,width*0.15,height*0.1))
.align_(\center)
.stringColor_(Color.white)
.string_("resolution");
resolutionKnob = Knob(window,Rect(width*0.7375,height*0.5,width*0.1,height*0.1))
.value_(1)
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	resolution = obj.value.linlin(0,1,resolutionRange[1],resolutionRange[0]).asInteger;
		currentState = {{2.rand}!(height/resolution).asInteger}!(width/resolution).asInteger;
});
StaticText(window,Rect(width*0.7125,height*0.6125,width*0.15,height*0.1))
.align_(\center)
.stringColor_(Color.white)
.string_("volume");
volumeKnob = Knob(window,Rect(width*0.7375,height*0.7,width*0.1,height*0.1))
.value_(amplitude.linlin(0.0,0.25,0,1))
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	amplitude = obj.value.linlin(0,1,0.0,0.25);
});
StaticText(window,Rect(width*0.8375,height*0.0125,width*0.15,height*0.1))
.align_(\center)
.stringColor_(Color.white)
.string_("jitter");
jitterKnob = Knob(window,Rect(width*0.8675,height*0.1,width*0.1,height*0.1))
.value_(0)
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	jitter = obj.value.linlin(0,1,0,jitterRange);
});
StaticText(window,Rect(width*0.8375,height*0.2125,width*0.15,height*0.1))
.align_(\center)
.stringColor_(Color.white)
.string_("rate");
rateKnob = Knob(window,Rect(width*0.8675,height*0.3,width*0.1,height*0.1))
.value_(0.5)
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	frameRate = obj.value.linlin(0,1,rateRange[0],rateRange[1]);
	attackRange[1] = 1.5*(1/frameRate);
	releaseRange[1] = 1.5*(1/frameRate);
	attack = attackKnob.value.linlin(0,1,attackRange[0],attackRange[1]);
	release = releaseKnob.value.linlin(0,1,releaseRange[0],releaseRange[1]);
});
StaticText(window,Rect(width*0.8375,height*0.4125,width*0.15,height*0.1))
.align_(\center)
.stringColor_(Color.white)
.string_("pitch range");
pitchKnob = Knob(window,Rect(width*0.8675,height*0.5,width*0.1,height*0.1))
.value_(0.5)
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
		maxFreq = obj.value.linexp(0,1,pitchRange[0],pitchRange[1]).asInteger;
});
StaticText(window,Rect(width*0.8375,height*0.635,width*0.15,height*0.1))
.align_(\center)
.stringColor_(Color.white)
.string_("wave: ");
waveSelector = PopUpMenu(window,Rect(width*0.865,height*0.725,width*0.1,height*0.05))
.items_(waveShapes)
.stringColor_(Color.white)
.background_(Color.new(0.4,0.4,0.4,1.0))
.action_({|obj|
	instrument = waveShapes[obj.value.asInteger];
});
runButton = Button(window,Rect(width*0.8675,height*0.9,width*0.1,height*0.075))
.states_([["RUN",Color.white,Color.new(0.4,0.4,0.4,1.0)]])
.action_({|obj|
	if(flagStart,{
		flagStart = false;
		obj.string = "RUN";
	},{
		flagStart = true;
		obj.string = "STOP";
	});
});
newButton = Button(window,Rect(width*0.7375,height*0.9,width*0.1,height*0.075))
.states_([["NEW",Color.white,Color.new(0.4,0.4,0.4,1.0)]])
.action_({
	currentState = {{2.rand}!(height/resolution).asInteger}!(width/resolution).asInteger;
});
Routine(
	{while({window.isClosed.not}, {
			canvas.refresh;
			if(flagNanoKontrol2,{
				if(flagStart == true){runButton.string = "STOP"}{runButton.string = "RUN"};
				attackKnob.valueAction_(attack.linlin(attackRange[0],attackRange[1],0,1));
				releaseKnob.valueAction_(release.linlin(releaseRange[0],releaseRange[1],0,1));
				volumeKnob.value_(amplitude.linlin(volumeRange[0],volumeRange[1],0,1));
				jitterKnob.value_(jitter.linlin(0,jitterRange,0,1));
				resolutionKnob.value_(resolution.linlin(resolutionRange[0],resolutionRange[1],1,0));
				rateKnob.value_(frameRate.linlin(rateRange[0],rateRange[1],0,1));
				waveSelector.value_(waveIdx);
				pitchKnob.value_(maxFreq.explin(pitchRange[0],pitchRange[1],0,1));
			});
			// (1/frameRate).wait;
			(1/rateRange[1]).wait;
	})}
).play(AppClock);
window.front;
window.alwaysOnTop_(true);
if(flagNanoKontrol2,{
	n.playBtn.onPress = {flagStart = true};
	n.stopBtn.onPress = {flagStart = false};
	n.markerSetBtn.onPress = {currentState = {{2.rand}!(height/resolution).asInteger}!(width/resolution).asInteger};
		n.knob1.onChange_({|val| attack = val.linlin(0,127,attackRange[0],attackRange[1])});
		n.knob2.onChange_({|val| release = val.linlin(0,127,attackRange[0],attackRange[1])});
		n.knob3.onChange_({|val|
			resolution = val.linlin(0,127,resolutionRange[1],resolutionRange[0]).asInteger;
			currentState = {{2.rand}!(height/resolution).asInteger}!(width/resolution).asInteger
		});
		n.knob4.onChange_({|val| amplitude = val.linlin(0,127,volumeRange[0],volumeRange[1])});
		n.knob5.onChange_({|val| jitter = val.linlin(0,127,0,jitterRange)});
		n.knob6.onChange_({|val|
			frameRate = val.linlin(0,127,rateRange[0],rateRange[1]);
			attackRange[1] = 1.5*(1/frameRate);
			releaseRange[1] = 1.5*(1/frameRate);
			attack = currentAttackKnobValue.linlin(0,1,attackRange[0],attackRange[1]);
			release = currentReleaseKnobValue.linlin(0,1,releaseRange[0],releaseRange[1]);
		});
		n.knob7.onChange_({|val| maxFreq = val.linlin(0,127,pitchRange[0],pitchRange[1])});
		n.knob8.onChange_({|val|
			var idx;
			waveIdx = val.linlin(0,127,0,waveShapes.size-1).asInteger;
			instrument = waveShapes[waveIdx]});
});
}
)












(
s.waitForBoot{
var window, polarCanvas, waveCanvas, radiusMultiSlider;
var polarArray, waveShapeArray, frameRate = 12, bufferSize = 1024,
range = (), rotationAngle = 0, sizeScale = 1, waveTable, synth, bufferL, bufferR, playFlag = false, volume = 0.5, amplitude = 0,th = 0, dh, nRose = 1, dRose = 1, aRose = 0, bRose = 1, flagMaurer = false;
var draw_polar_shape, draw_wave_shape, compute_wave_shape, compute_rose;
Window.closeAll;
Buffer.freeAll;
//// Add SynthDef ======================================================= ////
SynthDef.new(\wtosc,{
	arg bufL, bufR, freq = 100, amp = 0.2, at = 2, re = 2, gate = 1, phase = 0;
	var sig, env;
	env = EnvGen.kr(Env.asr(at,1.0,re,curve:0), gate: gate, doneAction:2);
	sig = [Osc.ar(bufL,freq,phase:phase),Osc.ar(bufR,freq,phase:phase)];
	Out.ar(0,sig * amp);
}).add;
//// init parameters ==================================================== ////
range.put('radius', [-100,175]);
range.put('amplitude', [0.1,0.01]);
range.put('frequency', [80,2000]);
polarArray = range.radius[1]!(bufferSize/2);
dh = 2*pi/(polarArray.size);
waveShapeArray = (0!(bufferSize/2))!2;
bufferL = Buffer.alloc(s,bufferSize);
bufferR = Buffer.alloc(s,bufferSize);
polarArray.size.do{|idx|
	waveShapeArray[0][idx] = (polarArray[idx].linlin(range.radius[0],range.radius[1],0,1))*cos(th);
	waveShapeArray[1][idx] = (polarArray[idx].linlin(range.radius[0],range.radius[1],0,1))*sin(th);
	th = th + dh;
};
waveTable = [Env(waveShapeArray[0],(1/(bufferSize/2))!(bufferSize/2)).asSignal(bufferSize/2).asWavetable,Env(waveShapeArray[1],(1/(bufferSize/2))!(bufferSize/2)).asSignal(bufferSize/2).asWavetable];
bufferL.sendCollection(waveTable[0]);
bufferR.sendCollection(waveTable[1]);
synth = Synth(\wtosc);
synth.set(\bufL,bufferL);
synth.set(\bufR,bufferR);
synth.set(\freq,range.frequency[0]);
synth.set(\amp,0);
//// functions ==================================================== ////
draw_polar_shape = {|center, radius, scale, rotation|
	var theta, dtheta, pos, n;
	n = radius.size;
	theta = rotation;
	dtheta = dRose*2*pi/n;
	Pen.strokeColor = Color.white;
	Pen.width_(4);
	n.do{|idx|
		if(flagMaurer,{
			pos = (center.x+(scale*radius[idx]*cos((nRose/dRose)*theta)))@(center.y+(scale*radius[idx]*sin((nRose/dRose)*theta)))
		},{
			pos = (center.x+(scale*radius[idx]*cos(theta)))@(center.y+(scale*radius[idx]*sin(theta)))
		});
		if(idx == 0,{
			Pen.moveTo(pos)
		},{
			Pen.lineTo(pos)
		});
		theta = theta + dtheta
	};
	Pen.lineTo(pos);
	Pen.stroke
};
draw_wave_shape = {|center, radius, rotation|
	var theta, dtheta, n, pos;
	n = radius.size;
	theta = rotation;
	dtheta = dRose*2*pi/n;
	Pen.strokeColor = Color.magenta;
	Pen.width_(4);
	n.do{|idx|
		pos = (center.x+idx)@(center.y + (radius[idx]*sin(theta)));
		if(idx == 0,{
			Pen.moveTo(pos)
		},{
			Pen.lineTo(pos)
		});
		waveShapeArray[0][idx] = (radius[idx].linlin(range.radius[0],range.radius[1],0,1))*cos(theta);
		theta = theta + dtheta;
	};
	Pen.stroke;
	Pen.strokeColor = Color.cyan;
	theta = rotation;
	n.do{|idx|
		pos = (center.x+idx)@(center.y + (radius[idx]*cos(theta)));
		if(idx == 0,{
			Pen.moveTo(pos)
		},{
			Pen.lineTo(pos)
		});
		waveShapeArray[1][idx] = (radius[idx].linlin(range.radius[0],range.radius[1],0,1))*sin(theta);
		theta = theta + dtheta;
	};
	Pen.stroke
};
compute_wave_shape.value();
compute_rose = {|nn,dd|
	var theta = 0, dtheta;
	dtheta = dd*2*pi/(polarArray.size);
	polarArray.size.do{|idx|
		polarArray[idx] = range.radius[1]*(aRose + bRose*cos((nn/dd)*theta));
		theta = theta + dtheta
	};
};
//// Window GUI ==================================================== ////
window = Window("POLAR WAVE SHAPER",
	Rect(1350,300,1000,600));
window.background = Color.new(0.2,0.2,0.2,1.0);
//// multislider of radial coordinate
radiusMultiSlider = MultiSliderView(window,
	Rect(0.025*window.bounds.width,
		0.7*window.bounds.height,
		0.4*window.bounds.width,
		0.25*window.bounds.height))
.size_((bufferSize/2))
.drawLines_(true)
.drawRects_(false)
.elasticMode_(true)
.colors_(Color.white)
.background_(Color.grey)
.value_(polarArray.linlin(range.radius[0],range.radius[1],0,1))
.action_({|obj|
	var temp = obj.value;
	flagMaurer = false;
	temp.size.do{|idx|
		polarArray[idx] = temp[idx].linlin(0,1,range.radius[0],range.radius[1]);
	};
	waveTable = [Env(waveShapeArray[0],(1/(bufferSize/2))!(bufferSize/2)).asSignal((bufferSize/2)).asWavetable,Env(waveShapeArray[1],(1/(bufferSize/2))!(bufferSize/2)).asSignal((bufferSize/2)).asWavetable];
	bufferL.sendCollection(waveTable[0]);
	bufferR.sendCollection(waveTable[1]);
});
//// rotation knob
StaticText(window,Rect(0.5125*window.bounds.width- (0.1*window.bounds.height),
		0.7125*window.bounds.height,
		100,50))
.align_(\center)
.stringColor_(Color.white)
.string_("rotation");
Knob(window,
	Rect(0.5375*window.bounds.width - (0.1*window.bounds.height),
		0.8*window.bounds.height,
		0.1*window.bounds.height,
		0.1*window.bounds.height))
.value_(0)
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	rotationAngle = obj.value.linlin(0,1,0,2*pi);
	waveTable = [Env(waveShapeArray[0],(1/(bufferSize/2))!(bufferSize/2)).asSignal((bufferSize/2)).asWavetable,Env(waveShapeArray[1],(1/(bufferSize/2))!(bufferSize/2)).asSignal((bufferSize/2)).asWavetable];
	bufferL.sendCollection(waveTable[0]);
	bufferR.sendCollection(waveTable[1]);
});
//// size (frequency) knob
StaticText(window,Rect(0.6125*window.bounds.width - (0.1*window.bounds.height),
		0.7125*window.bounds.height,
		100,50))
.align_(\center)
.stringColor_(Color.white)
.string_("size");
Knob(window,
	Rect(0.6375*window.bounds.width- (0.1*window.bounds.height),
		0.8*window.bounds.height,
		0.1*window.bounds.height,
		0.1*window.bounds.height))
.value_(0)
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	sizeScale = obj.value.linlin(0,1,0.15,1.0);
	synth.set(\freq,obj.value.linexp(0,1,range.frequency[1],range.frequency[0]));
	amplitude = obj.value.linexp(0,1,range.amplitude[1],range.amplitude[0]);
	if(playFlag,{synth.set(\amp,volume*amplitude)});
});
//// rose knobs
StaticText(window,Rect(0.7*window.bounds.width - (0.1*window.bounds.height),
		0.725*window.bounds.height,
		100,50))
.align_(\center)
.stringColor_(Color.white)
.string_("n");
Knob(window,
	Rect(0.7125*window.bounds.width,
		0.725*window.bounds.height,
		0.1*window.bounds.height,
		0.1*window.bounds.height))
.value_(nRose.linlin(0,10,0,1))
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	nRose = obj.value.linlin(0,1,1,20).asInteger;
	// flagMaurer = true;
	compute_rose.value(nRose,dRose);
	waveTable = [Env(waveShapeArray[0],(1/(bufferSize/2))!(bufferSize/2)).asSignal((bufferSize/2)).asWavetable,Env(waveShapeArray[1],(1/(bufferSize/2))!(bufferSize/2)).asSignal((bufferSize/2)).asWavetable];
	bufferL.sendCollection(waveTable[0]);
	bufferR.sendCollection(waveTable[1]);
});
StaticText(window,Rect(0.7*window.bounds.width - (0.1*window.bounds.height),
	0.865*window.bounds.height,
	100,50))
.align_(\center)
.stringColor_(Color.white)
.string_("d");
Knob(window,
	Rect(0.7125*window.bounds.width,
		0.85*window.bounds.height,
		0.1*window.bounds.height,
		0.1*window.bounds.height))
.value_(dRose.linlin(1,10,0,1))
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	dRose = obj.value.linlin(0,1,1,20).asInteger;
	// flagMaurer = true;
	compute_rose.value(nRose,dRose);
	waveTable = [Env(waveShapeArray[0],(1/(bufferSize/2))!(bufferSize/2)).asSignal((bufferSize/2)).asWavetable,Env(waveShapeArray[1],(1/(bufferSize/2))!(bufferSize/2)).asSignal((bufferSize/2)).asWavetable];
	bufferL.sendCollection(waveTable[0]);
	bufferR.sendCollection(waveTable[1]);
});
//// volume (synth amplitude) knob
StaticText(window,Rect(0.775*window.bounds.width + (0.1*window.bounds.height),
		0.65*window.bounds.height,
		100,50))
.align_(\center)
.stringColor_(Color.white)
.string_("volume");
Knob(window,
	Rect(0.795*window.bounds.width + (0.1*window.bounds.height),
		0.735*window.bounds.height,
		0.1*window.bounds.height,
		0.1*window.bounds.height))
.value_(volume)
.color_([Color.white,Color.white,Color.grey,Color.grey])
.action_({|obj|
	volume = obj.value;
	if(playFlag,{synth.set(\amp,volume*amplitude)});
});
Button(window,Rect(window.bounds.width*0.775 + (0.1*window.bounds.height),
	window.bounds.height*0.875,
	window.bounds.width*0.1,
	window.bounds.width*0.05))
.states_([["PLAY",Color.white,Color.new(0.4,0.4,0.4,1.0)]])
.action_({|obj|
	if(playFlag,{
		playFlag = false;
		synth.set(\amp,0);
		obj.string = "PLAY";
	},{
		playFlag = true;
		synth.set(\amp,volume*amplitude);
		obj.string = "STOP";
	});
});
//// Polar Canvas ==================================================== ////
polarCanvas = UserView(window,
	Rect(0.025*window.bounds.width,
		0.05*window.bounds.height,
		0.4*window.bounds.width,
		0.6*window.bounds.height));
polarCanvas.background = Color.grey;
polarCanvas.drawFunc = {
	Pen.strokeColor = Color.magenta;
	Pen.width_(2);
	Pen.line((polarCanvas.bounds.width/2)@0,
		(polarCanvas.bounds.width/2)@polarCanvas.bounds.height);
	Pen.stroke;
	Pen.strokeColor = Color.cyan;
	Pen.line(0@(polarCanvas.bounds.height/2),
		polarCanvas.bounds.width@(polarCanvas.bounds.height/2));
	Pen.stroke;
	draw_polar_shape.value((polarCanvas.bounds.width/2)@(polarCanvas.bounds.height/2),
		polarArray,sizeScale,rotationAngle)
};
//// Wave Canvas ==================================================== ////
waveCanvas = UserView(window,
	Rect(0.45*window.bounds.width,
		0.05*window.bounds.height,bufferSize/2,0.6*window.bounds.height));
waveCanvas.background = Color.grey;
waveCanvas.drawFunc = {
	Pen.strokeColor = Color.black;
	Pen.width_(2);
	Pen.line(0@(waveCanvas.bounds.height/2),
		waveCanvas.bounds.width@(waveCanvas.bounds.height/2));
	Pen.stroke;
	draw_wave_shape.value(0@(waveCanvas.bounds.height/2),polarArray,rotationAngle);
};
//// Main frame loop ==================================================== ////
Routine(
	{while({window.isClosed.not}, {
			polarCanvas.refresh;
		waveCanvas.refresh;
			(1/frameRate).wait
	})}
).play(AppClock);
window.front;
window.alwaysOnTop_(true);
window.onClose = {
	synth.free;
};
}
)

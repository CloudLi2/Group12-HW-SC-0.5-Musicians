//Readme: run all command and blocks one by one, now it reads the .wav i send in Whatsapp, also possible to change input to whitenoise to observe spectrum or real instrument.

s.boot       //boot server

s.scope      //monitor bus signals
s.freqscope  //freq spectrum
s.meter      //volumn


//change the directory

b = Buffer.read(s,"/Users/zhoujian/Downloads/HW1/Guitar.wav");   //Mac user use this line and modify the audio file path

//b = Buffer.read(s,"C:/Users/pc/Desktop/HW1/Guitar.wav");  //Win user use this line and modify the aduio file path


//------------Wah wah--------------(x)
(
SynthDef(\wah,{
	arg mix=0, freqBand=0, bw=0, inBus, outBus;
	var sgn,x_n,x_n_out,y_n;

	x_n = In.ar(inBus, 2);

	freqBand = 1 - freqBand;  //inverse the para to act like a real wahwah
	sgn = BBandPass.ar(x_n, 2599*freqBand+300, 3*bw+0.05);

	y_n = (0.5 * x_n * (1-mix)) + (sgn * mix);
	Out.ar(outBus, Pan2.ar(y_n));

}).add;
)


//-------------Phaser----------------(y)
(
SynthDef(\phaser, {
	arg inBus=4, outBus = 0, freq1 = 500, freq2 = 1000, freq3 = 3000, freq4 = 5000, kfreq = 0, kmul = 0, rq = 1, depth = 0, num = 0;
    var input, sig, dry, wet1, wet2, wet3, out;

    input = In.ar(inBus, 2);
	dry = input;
	kmul = kmul * 500;  //width
	kfreq = kfreq * 8;  //rate

	sig = SelectX.ar(  //choose from 3 options
		num.varlag(1),
		[
			BAllPass.ar(input, SinOsc.kr(kfreq, 0, kmul, freq1), rq),
			wet1 = BAllPass.ar(input, SinOsc.kr(kfreq, 0, kmul, freq1), rq); BAllPass.ar(wet1, SinOsc.kr(kfreq, 0, kmul, freq2), rq),
			wet1 = BAllPass.ar(input, SinOsc.kr(kfreq, 0, kmul, freq1), rq);	wet2 = BAllPass.ar(wet1, SinOsc.kr(kfreq, 0, kmul, freq2), rq); wet3 = BAllPass.ar(wet2, SinOsc.kr(kfreq, 0, kmul, freq3), rq); BAllPass.ar(wet3, SinOsc.kr(kfreq, 0, kmul, freq4), rq);
		]
	);

	out = dry + (sig * depth);
	Out.ar(outBus, Pan2.ar(0.6 * out));

}).add;
)


//-------------Flanger----------------(z)
(
SynthDef(\flanger, {
	arg inBus=6, outBus=0, bufnum, rate=0, width=0, feedback=0, mix=0; //width:0.1-2.5
    var inSig, outSig, lfo, delay, mixed;

	inSig = In.ar(inBus, 2);

    // LFO, Delay
	lfo = SinOsc.kr(rate * 2, 0, 0.002 * width); // *0-2ms delay. dial from 0-1. also normalizes every gui para.

	//delay = DelayL.ar(inSig, 0.01, 0.0025 + lfo, 1, 0);  //DelayL method has no feedback
	delay = CombL.ar(inSig, 0.01, 0.0025 + lfo, 0.05 * feedback, 1, 0);
	mix = 0.5 * mix;
	mixed = (0.7 * inSig * (1-mix)) + (delay * mix);

	Out.ar(0, Pan2.ar(0.9 * mixed));

}).add;
)







//-----------------GUI Interface------------------all knobs, sliders take value from 0-1
(
var btnPlay,mixWahKnob,bwKnob,centralFreqSlider,depthKnob, controlFreqKnob, widthPhaserKnob,mixFlangerKnob,rateKnob,widthFlangerKnob, feedback, modeKnob;
var menu, snd, funcs, b;

w = Window("my Window", Rect(Window.screenBounds.width/2-400, Window.screenBounds.height/2-250,780,370), false);//main window
StaticText(w,Rect(40,50,180,300)).background_(Color.grey(0.2));
StaticText(w,Rect(280,50,180,300)).background_(Color.new255(4,191,85));
StaticText(w,Rect(530,50,180,300)).background_(Color.new255(186,85,211));

StaticText(w,Rect(40,45,180,50)).string_("Wah-Wah").stringColor_(Color.white).font_(Font("Arial Black", 18)).align_(\center);
StaticText(w,Rect(280,45,180,50)).string_("Phaser").stringColor_(Color.black).font_(Font("Arial Black", 18)).align_(\center);
StaticText(w,Rect(530,45,180,50)).string_("Flanger").stringColor_(Color.black).font_(Font("Arial Black", 18)).align_(\center);

w.view.background_(Color.grey(0.8));
w.alwaysOnTop=true;

w.front; //show
// w.alwaysOnTop_(true);

//GENERAL

g = ControlSpec.new(0,1,\lin);
c = ControlSpec.new(0,2,\lin,1);

//init effects
z = Synth(\flanger, [\inBus, 6, \outBus, 0]);
y = Synth(\phaser, [\inBus, 4, \outBus, 6]);
x = Synth(\wah, [\inBus, 10, \outBus, 4]);


//-----------Wah Wah--------------

//mix .knob
mixWahKnob = Knob(w,bounds:Rect(60,115,55,55)).mode_(\vert);
mixWahKnob.color_([Color.new255(100,202,234), Color.new255(10,150,234), Color.white]);
mixWahKnob.action_({ arg obj;
	x.set(\mix, obj.value);     //mix .knob
});
StaticText(w,Rect(60,80,50,50)).string_("MIX").stringColor_(Color.white).font_(Font("Arial Black", 12)).align_(\center);


//bandwidth .knob
bwKnob = Knob(w,bounds:Rect(150,115,55,55)).mode_(\vert);
bwKnob.color_([Color.new255(100,202,234), Color.new255(10,150,234), Color.white]);
bwKnob.action_({ arg obj;
	x.set(\bw, obj.value);      //bandwidth .knob
});
StaticText(w,Rect(150,80,50,50)).string_("WIDTH").stringColor_(Color.white).font_(Font("Arial Black",12)).align_(\center);


//centrefreq .slider
centralFreqSlider = Slider(parent:w,bounds:Rect(80,180,100,150)).orientation_(\vertical);
centralFreqSlider.thumbSize_(40).knobColor_(Color.blue);
centralFreqSlider.action_({ arg obj;
	x.set(\freqBand, obj.value);  //centrefreq .slider
});



//-------------Phaser----------------(y)

//depth basically = mix .knob
depthKnob = Knob(w,bounds:Rect(300,155,55,55)).mode_(\vert);
depthKnob.color_([Color.grey(0.7), Color.black, Color.white]);
depthKnob.action_({ arg obj;
	y.set(\depth, obj.value);  //depth basically = mix .knob
});
StaticText(w,Rect(300,120,50,50)).string_("MIX").stringColor_(Color.black).font_(Font("Arial Black", 12)).align_(\center);


//control freq .knob
controlFreqKnob = Knob(w,bounds:Rect(390,155,55,55)).mode_(\vert);
controlFreqKnob.color_([Color.grey(0.7), Color.black, Color.white]);
controlFreqKnob.action_({ arg obj;
	y.set(\kfreq, obj.value);  //control freq .knob
});
StaticText(w,Rect(390,120,50,50)).string_("RATE").stringColor_(Color.black).font_(Font("Arial Black", 12)).align_(\center);


//width .knob
widthPhaserKnob = Knob(w,bounds:Rect(300,265,55,55)).mode_(\vert);
widthPhaserKnob.color_([Color.grey(0.7), Color.black, Color.white]);
widthPhaserKnob.action_({ arg obj;
	y.set(\kmul, obj.value);   //width .knob
});
StaticText(w,Rect(300,230,50,50)).string_("WIDTH").stringColor_(Color.black).font_(Font("Arial Black", 12)).align_(\center);


//mode(0,1,2) .knob or button
modeKnob = EZKnob(w,bounds:Rect(390,265,55,55),controlSpec: c,layout:\vert,margin: m,labelHeight:0);
modeKnob.action_({
	y.set(\num, modeKnob.value);    //mode(0,1,2) .knob or button
});
StaticText(w,Rect(390,230,50,50)).string_("MODE").stringColor_(Color.black).font_(Font("Arial Black", 12)).align_(\center);



//-------------Flanger----------------(z)

//mix .knob
mixFlangerKnob = Knob(w,bounds:Rect(550,155,55,55)).mode_(\vert);
mixFlangerKnob.color_([Color.grey(0.7), Color.black, Color.white]);
mixFlangerKnob.action_({ arg obj;
	z.set(\mix, obj.value);    //mix .knob
});
StaticText(w,Rect(550,120,50,50)).string_("MIX").stringColor_(Color.black).font_(Font("Arial Black", 12)).align_(\center);


//rate .knob
rateKnob = Knob(w,bounds:Rect(640,155,55,55)).mode_(\vert);
rateKnob.color_([Color.grey(0.7), Color.black, Color.white]);
rateKnob.action_({ arg obj;
	z.set(\rate, obj.value); //rate .knob
});
StaticText(w,Rect(640,120,50,50)).string_("RATE").stringColor_(Color.black).font_(Font("Arial Black", 12)).align_(\center);


//width .knob
widthFlangerKnob = Knob(w,bounds:Rect(550,265,55,55)).mode_(\vert);
widthFlangerKnob.color_([Color.grey(0.7), Color.black, Color.white]);
widthFlangerKnob.action_({ arg obj;
	z.set(\width, obj.value);  //width .knob
});
StaticText(w,Rect(550,230,50,50)).string_("WIDTH").stringColor_(Color.black).font_(Font("Arial Black", 12)).align_(\center);


//feedback .knob
feedback = Knob(w,bounds:Rect(640,265,55,55)).mode_(\vert);
feedback.color_([Color.grey(0.7), Color.black, Color.white]);
feedback.action_({ arg obj;
z.set(\feedback, obj.value); //feedback .knob
});
StaticText(w,Rect(640,230,50,50)).string_("REGEN").stringColor_(Color.black).font_(Font("Arial Black", 12)).align_(\center);


//---------------------PopUpMenu-------------------------
menu = PopUpMenu(w, Rect(10, 10, 90, 20)).items_(["Instrument", "Demo", "WhiteNoise"]);

	funcs = [
		{ SoundIn.ar(0!2) },
		{ PlayBuf.ar(2, 0, BufRateScale.kr(0), doneAction: Done.freeSelf) },
		{ 0.4 * WhiteNoise.ar(0.5).dup }
	];

//------------button play/stop
b = Button(w, Rect(110, 10, 180, 20))
	.states_([["play", Color.black, Color.green], ["stop", Color.black, Color.red]])
	.mouseDownAction_({
		snd = funcs.at(menu.value);

		//snd = menu.value;
	})
	.action_({ arg obj; //arg butt, mod;
		if(obj.value == 1) { w = {Out.ar(10, snd)}.play; obj.value.postln;} { w.free; obj.value.postln;}
		//snd.release;
	});


p = CmdPeriod.add({ b.value_(0) }); // set button to 0 on hitting Cmd-period
w.onClose_{ snd.release; CmdPeriod.removeAll; CmdPeriod.run;}; // clean up when window is closed


)


//******************************************//

//------Play Instrument-------
//x = {SoundIn.ar(0!2)}.play;
//x.free;
/*
(
z = Synth(\flanger, [\inBus, 6, \outBus, 0]);
y = Synth(\phaser, [\inBus, 4, \outBus, 6]);
x = Synth(\wah, [\inBus, 10, \outBus, 4]);

w = Synth(\white, [\outBus, 10]);
)*/

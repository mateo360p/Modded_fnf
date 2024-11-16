package;

import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxSort;
import Section.SwagSection;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var disChangeZ:Bool = false; //ONLY FOR BLAZIN SONG 

	public var mostRecentRow:Int = 0;
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		var library:String = null;
		switch (curCharacter)
		{
			//case 'your character name in case you want to hardcode them instead':

			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';

				#if MODS_ALLOWED
				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				#if MODS_ALLOWED
				var rawJson = File.getContent(path);
				#else
				var rawJson = Assets.getText(path);
				#end

				var json:CharacterFile = cast Json.parse(rawJson);
				var spriteType = "sparrow";
				//sparrow
				//packer
				//texture
				#if MODS_ALLOWED
				var modTxtToFind:String = Paths.modsTxt(json.image);
				var txtToFind:String = Paths.getPath('images/' + json.image + '.txt', TEXT);
				
				//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
				//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
				
				if (FileSystem.exists(modTxtToFind) || FileSystem.exists(txtToFind) || Assets.exists(txtToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT)))
				#end
				{
					spriteType = "packer";
				}
				
				#if MODS_ALLOWED
				var modAnimToFind:String = Paths.modFolders('images/' + json.image + '/Animation.json');
				var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT);
				
				//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
				//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
				
				if (FileSystem.exists(modAnimToFind) || FileSystem.exists(animToFind) || Assets.exists(animToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json', TEXT)))
				#end
				{
					spriteType = "texture";
				}

				switch (spriteType){
					
					case "packer":
						frames = Paths.getPackerAtlas(json.image);
					
					case "sparrow":
						frames = Paths.getSparrowAtlas(json.image);
					
					case "texture":
						frames = AtlasFrameMaker.construct(json.image);
				}
				imageFile = json.image;

				if(json.scale != 1) {
					jsonScale = json.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				positionArray = json.position;
				cameraPosition = json.camera_position;

				healthIcon = json.healthicon;
				singDuration = json.sing_duration;
				flipX = !!json.flip_x;
				if(json.no_antialiasing) {
					antialiasing = false;
					noAntialiasing = true;
				}

				if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
					healthColorArray = json.healthbar_colors;

				antialiasing = !noAntialiasing;
				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop; //Bruh
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}

						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
				} else {
					quickAnimAdd('idle', 'BF idle dance');
				}
				//trace('Loaded file to character ' + curCharacter);

				/*ABOT STUFF
				if (curCharacter == 'nene'){
					var abot = new Abot(x, y);
					add(abot);
				}*/
		}
		originalFlipX = flipX;

		if(animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss')) hasMissAnimations = true;
		recalculateDanceIdle();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			/*// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				if(animation.getByName('singLEFT') != null && animation.getByName('singRIGHT') != null)
				{
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;
				}

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singLEFTmiss') != null && animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}*/
		}

		switch(curCharacter)
		{
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
		}
	}

	var playBF = PlayState.instance.boyfriend;
	var playDad = PlayState.instance.dad;
	//Only for blazin
	function moveToBack(?xd:Dynamic){
		if (playBF != null && playDad != null){
			playBF.zIndex = 90;
			playDad.zIndex = 100;
			PlayState.instance.refreshState();
		}
	}

	function moveToFront(?xd:Dynamic){
		if (playBF != null && playDad != null){
			playBF.zIndex = 100;
			playDad.zIndex = 90;
			PlayState.instance.refreshState();
		}
	}
	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed * PlayState.instance.playbackRate;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}
			
			switch(curCharacter)
			{
				case 'pico-speaker':
					if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
					{
						var noteData:Int = 1;
						if(animationNotes[0][1] > 2) noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}
					if(animation.curAnim.finished) playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
			}
			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * (0.0011 / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1)) * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if (!isPlayer)
			{
				if (PlayState.curStage == 'phillyBlazin'){
					moveToBack(true);
				}
			} else {
				if (PlayState.curStage == 'phillyBlazin'){
					moveToFront(true);
				}
			}
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null) {
					playAnim('idle' + idleSuffix);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}
	
	function loadMappedAnims():Void
	{
		var noteData:Array<SwagSection> = Song.loadFromJson('picospeaker', Paths.formatToSongPath(PlayState.SONG.song)).notes;
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				animationNotes.push(songNotes);
			}
		}
		TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}

	//DARNELL BLAZIN CHITS

	var alternate:Bool = false;
	function doAlternate():String {
		alternate = !alternate;
		return alternate ? '1' : '2';
	}

	function playBlockAnim()
	{
		playAnim('block', true, false);
		PlayState.instance.camGame.shake(0.002, 0.1);
		//moveToBack();
	}

	function playCringeAnim()
	{
		playAnim('cringe', true, false);
		//moveToBack();
	}

	function playDodgeAnim()
	{
		playAnim('dodge', true, false);
		//moveToBack();
	}

	function playIdleAnim()
	{
		playAnim('idle', false, false);
		//moveToBack();
	}

	function playFakeoutAnim()
	{
		playAnim('fakeout', true, false);
		//moveToBack();
	}

	function playPissedConditionalAnim()
	{
		if (animation.curAnim.name == "cringe") {
			playPissedAnim();
		} else {
			playIdleAnim();
		}
	}

	function playPissedAnim()
	{
		playAnim('pissed', true, false);
		//moveToBack();
	}

	function playUppercutPrepAnim()
	{
		playAnim('uppercutPrep', true, false);
		//moveToFront(this);
	}

	//hit parameter doesn't matter for darnell, just put true or false
	function playUppercutAnim(hit:Bool)
	{
		playAnim('uppercut', true, false);
		//moveToFront();
	}

	function playUppercutHitAnim()
	{
		playAnim('uppercutHit', true, false);
		//moveToBack();
	}

	function playHitHighAnim()
	{
		playAnim('hitHigh', true, false);
		PlayState.instance.camGame.shake(0.0025, 0.15);
		//moveToBack();
	}

	function playHitLowAnim()
	{
		playAnim('hitLow', true, false);
		PlayState.instance.camGame.shake(0.0025, 0.15);
		//moveToBack();
	}

	function playPunchHighAnim()
	{
		playAnim('punchHigh' + doAlternate(), true, false);
		//moveToFront();
	}

	function playPunchLowAnim()
	{
		playAnim('punchLow' + doAlternate(), true, false);
		//moveToFront();
	}

	function playSpinAnim()
	{
		playAnim('hitSpin', true, false);
		PlayState.instance.camGame.shake(0.0025, 0.15);
		//moveToBack();
	}

    var cantUppercut = false;
    public function playBlazinAnimation(noteName:String, notHitByPlayer:Bool){

		this.disChangeZ == notHitByPlayer;

		if (!StringTools.startsWith(noteName, 'weekend-1-')) return;

        var shouldDoUppercutPrep = (PlayState.instance.health <= 0.30 * 2.0) && FlxG.random.bool(30);
/*
		if (shouldDoUppercutPrep) {
			playUppercutPrepAnim();
			return;
		}

		if (cantUppercut) {
			playPunchHighAnim();
			return;
		}*/

		/*
        switch(noteName) {
            case "weekend-1-punchlow":
				playPunchLowAnim();
			case "weekend-1-punchlowblocked":
				playPunchLowAnim();
			case "weekend-1-punchlowdodged":
				playPunchLowAnim();
			case "weekend-1-punchlowspin":
				playPunchLowAnim();

			// Pico tried and failed to punch, punch back!
			case "weekend-1-punchhigh":
				playPunchHighAnim();
			case "weekend-1-punchhighblocked":
				playPunchHighAnim();
			case "weekend-1-punchhighdodged":
				playPunchHighAnim();
			case "weekend-1-punchhighspin":
				playPunchHighAnim();

			// Attempt to punch, Pico dodges or gets hit.
			case "weekend-1-blockhigh":
				playPunchHighAnim();
			case "weekend-1-blocklow":
				playPunchLowAnim();
			case "weekend-1-blockspin":
				playPunchHighAnim();

			// Attempt to punch, Pico dodges or gets hit.
			case "weekend-1-dodgehigh":
				playPunchHighAnim();
			case "weekend-1-dodgelow":
				playPunchLowAnim();
			case "weekend-1-dodgespin":
				playPunchHighAnim();

			// Attempt to punch, Pico ALWAYS gets hit.
			case "weekend-1-hithigh":
				playPunchHighAnim();
			case "weekend-1-hitlow":
				playPunchLowAnim();
			case "weekend-1-hitspin":
				playPunchHighAnim();

			// Successfully dodge the uppercut.
			case "weekend-1-picouppercutprep":
				playHitHighAnim();
				cantUppercut = true;
			case "weekend-1-picouppercut":
				playDodgeAnim();

			// Attempt to punch, Pico dodges or gets hit.
			case "weekend-1-darnelluppercutprep":
				playUppercutPrepAnim();
			case "weekend-1-darnelluppercut":
				playUppercutAnim(true);

			case "weekend-1-idle":
				playIdleAnim();
			case "weekend-1-fakeout":
				playCringeAnim(); // TODO: Which anim?
			case "weekend-1-taunt":
				playPissedConditionalAnim();
			case "weekend-1-tauntforce":
				playPissedAnim();
			case "weekend-1-reversefakeout":
				playFakeoutAnim(); // TODO: Which anim?

			default:
				trace('idk');
				*/

		switch (noteName)	//OK MAYBE THERE'S A BETTER WAY TO DO THIS, but nah, this is, uhhh, okay :D
		{
			case "weekend-1-punchlow":
				if (notHitByPlayer) playPunchLowAnim();
				if (!notHitByPlayer) playHitLowAnim();
			case "weekend-1-punchlowblocked":
				if (notHitByPlayer) playPunchLowAnim();
				if (!notHitByPlayer) playBlockAnim();
			case "weekend-1-punchlowdodged":
				if (notHitByPlayer) playPunchLowAnim();
				if (!notHitByPlayer) playDodgeAnim();
			case "weekend-1-punchlowspin":
				if (notHitByPlayer) playPunchLowAnim();
				if (!notHitByPlayer) playSpinAnim();

			case "weekend-1-punchhigh":
				if (notHitByPlayer) playPunchHighAnim();
				if (!notHitByPlayer) playHitHighAnim();
			case "weekend-1-punchhighblocked":
				if (notHitByPlayer) playPunchHighAnim();
				if (!notHitByPlayer) playBlockAnim();
			case "weekend-1-punchhighdodged":
				if (notHitByPlayer) playPunchHighAnim();
				if (!notHitByPlayer) playDodgeAnim();
			case "weekend-1-punchhighspin":
				if (notHitByPlayer) playPunchHighAnim();
				if (!notHitByPlayer) playSpinAnim();

			case "weekend-1-blockhigh":
				if (notHitByPlayer) playBlockAnim();
				if (!notHitByPlayer) playPunchHighAnim();
			case "weekend-1-blocklow": //bro this one doesn't make any sense
				if (notHitByPlayer) playDodgeAnim(); //changed to dodge***
				if (!notHitByPlayer) playPunchLowAnim();
			case "weekend-1-blockspin":
				if (notHitByPlayer) playBlockAnim();
				if (!notHitByPlayer) playPunchHighAnim();

			case "weekend-1-dodgehigh":
				if (notHitByPlayer) playDodgeAnim();
				if (!notHitByPlayer) playPunchHighAnim();
			case "weekend-1-dodgelow":
				if (notHitByPlayer) playDodgeAnim();
				if (!notHitByPlayer) playPunchLowAnim();
			case "weekend-1-dodgespin":
				if (notHitByPlayer) playDodgeAnim();
				if (!notHitByPlayer) playPunchHighAnim();

			case "weekend-1-hithigh":
				if (notHitByPlayer) playHitHighAnim();
				if (!notHitByPlayer) playPunchHighAnim();
			case "weekend-1-hitlow":
				if (notHitByPlayer) playHitLowAnim();
				if (!notHitByPlayer) playPunchLowAnim();
			case "weekend-1-hitspin":
				if (notHitByPlayer) playSpinAnim();
				if (!notHitByPlayer) playPunchHighAnim();

			case "weekend-1-uppercutprep":
				if (notHitByPlayer) playUppercutPrepAnim();
				if (!notHitByPlayer) playIdleAnim();
			case "weekend-1-uppercut":
				if (notHitByPlayer) playUppercutAnim(true);
				if (!notHitByPlayer) playUppercutHitAnim();

			case "weekend-1-idle":
				if (notHitByPlayer) playIdleAnim();
			case "weekend-1-fakeout":
				if (notHitByPlayer) playFakeoutAnim();
				if (!notHitByPlayer) playIdleAnim();
			case "weekend-1-taunt":
				if (!notHitByPlayer) playPissedConditionalAnim();
			case "weekend-1-tauntforce":
				if (notHitByPlayer) playPissedAnim();

			default:
				// trace('Unknown note kind: ' + event.note.kind);	
		}
        
        cantUppercut = false;
		specialAnim = true;
    }
}

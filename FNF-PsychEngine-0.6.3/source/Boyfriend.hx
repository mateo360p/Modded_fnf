package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class Boyfriend extends Character
{
	public var startedDeath:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}

	override function playBlockAnim()
	{
		playAnim('block', true, false);
		PlayState.instance.camGame.shake(0.002, 0.1);
		moveToBack();
	}

	override function playCringeAnim()
	{
		playAnim('cringe', true, false);
		moveToBack();
	}

	override function playDodgeAnim()
	{
		playAnim('dodge', true, false);
		moveToBack();
	}

	override function playIdleAnim()
	{
		playAnim('idle', false, false);
		moveToBack();
	}

	override function playFakeoutAnim()
	{
		playAnim('fakeout', true, false);
		moveToBack();
	}

	override function playUppercutPrepAnim()
	{
		playAnim('uppercutPrep', true, false);
		moveToFront();
	}

	override function playUppercutAnim(hit:Bool)
	{
		playAnim('uppercut', true, false);
		if (hit) {
			PlayState.instance.camGame.shake(0.005, 0.25);
		}
		moveToFront();
	}

	override function playUppercutHitAnim()
	{
		playAnim('uppercutHit', true, false);
		PlayState.instance.camGame.shake(0.005, 0.25);
		moveToBack();
	}

	override function playHitHighAnim()
	{
		playAnim('hitHigh', true, false);
		PlayState.instance.camGame.shake(0.0025, 0.15);
		moveToBack();
	}

	override function playHitLowAnim()
	{
		playAnim('hitLow', true, false);
		PlayState.instance.camGame.shake(0.0025, 0.15);
		moveToBack();
	}

	function playHitSpinAnim()
	{
		playAnim('hitSpin', true, true);
		PlayState.instance.camGame.shake(0.0025, 0.15);
		moveToBack();
	}

	override function playPunchHighAnim()
	{
		playAnim('punchHigh' + doAlternate(), true, false);
		moveToFront();
	}

	override function playPunchLowAnim()
	{
		playAnim('punchLow' + doAlternate(), true, false);
		moveToFront();
	}

	function playTauntConditionalAnim()
	{
		if (animation.curAnim.name == "fakeout") {
			playTauntAnim();
		} else {
			playIdleAnim();
		}
	}

	function playTauntAnim()
	{
		playAnim('taunt', true, false);
		moveToBack();
	}

	/*
	function isDarnellInUppercut():Void {
		return
			getDarnell().getCurrentAnimation() == 'uppercut'
			|| getDarnell().getCurrentAnimation() == 'uppercut-hold';
	}*/

    public function playBlazinAnim(noteName:String, hitByPlayer:Bool, shouldUpperCut:Bool){

		this.disChangeZ == hitByPlayer;

		if (!StringTools.startsWith(noteName, 'weekend-1-')) return;

		var shouldDoUppercutPrep = (PlayState.instance.health <= 0.30 * 2.0) && shouldUpperCut;

		holdTimer = 0;

		/*
		if (shouldDoUppercutPrep) {
			playPunchHighAnim();
			return;
		}

		if (cantUppercut) {
			playBlockAnim();
			cantUppercut = false;
			return;
		}*/

		switch (noteName)	//OK MAYBE THERE'S A BETTER WAY TO DO THIS, but nah, this is, uhhh, okay :D
		{
			case "weekend-1-punchlow":
				if (hitByPlayer) playPunchLowAnim();
				if (!hitByPlayer) playHitLowAnim();
			case "weekend-1-punchlowblocked":
				if (hitByPlayer) playPunchLowAnim();
				if (!hitByPlayer) playBlockAnim();
			case "weekend-1-punchlowdodged":
				if (hitByPlayer) playPunchLowAnim();
				if (!hitByPlayer) playDodgeAnim();
			case "weekend-1-punchlowspin":
				if (hitByPlayer) playPunchLowAnim();
				if (!hitByPlayer) playHitSpinAnim();

			case "weekend-1-punchhigh":
				if (hitByPlayer) playPunchHighAnim();
				if (!hitByPlayer) playHitHighAnim();
			case "weekend-1-punchhighblocked":
				if (hitByPlayer) playPunchHighAnim();
				if (!hitByPlayer) playBlockAnim();
			case "weekend-1-punchhighdodged":
				if (hitByPlayer) playPunchHighAnim();
				if (!hitByPlayer) playDodgeAnim();
			case "weekend-1-punchhighspin":
				if (hitByPlayer) playPunchHighAnim();
				if (!hitByPlayer) playHitSpinAnim();

			case "weekend-1-blockhigh":
				if (hitByPlayer) playBlockAnim();
				if (!hitByPlayer) playPunchHighAnim();
			case "weekend-1-blocklow":
				if (hitByPlayer) playDodgeAnim();
				if (!hitByPlayer) playPunchLowAnim();
			case "weekend-1-blockspin":
				if (hitByPlayer) playBlockAnim();
				if (!hitByPlayer) playPunchHighAnim();

			case "weekend-1-dodgehigh":
				if (hitByPlayer) playDodgeAnim();
				if (!hitByPlayer) playPunchHighAnim();
			case "weekend-1-dodgelow":
				if (hitByPlayer) playDodgeAnim();
				if (!hitByPlayer) playPunchLowAnim();
			case "weekend-1-dodgespin":
				if (hitByPlayer) playDodgeAnim();
				if (!hitByPlayer) playPunchHighAnim();

			// Pico ALWAYS gets punched.
			case "weekend-1-hithigh":
				if (hitByPlayer) playHitHighAnim();
				if (!hitByPlayer) playPunchHighAnim();
			case "weekend-1-hitlow":
				if (hitByPlayer) playHitLowAnim();
				if (!hitByPlayer) playPunchLowAnim();
			case "weekend-1-hitspin":
				if (hitByPlayer) playHitSpinAnim();
				if (!hitByPlayer) playPunchHighAnim();

			case "weekend-1-uppercutprep":
				if (hitByPlayer) playUppercutPrepAnim();
				if (!hitByPlayer) playIdleAnim();
			case "weekend-1-uppercut":
				if (hitByPlayer) playUppercutAnim(true);
				if (!hitByPlayer) playUppercutHitAnim();

			case "weekend-1-idle":
				if (hitByPlayer) playIdleAnim();
			case "weekend-1-fakeout":
				if (hitByPlayer) playFakeoutAnim();
				if (!hitByPlayer) playIdleAnim();
			case "weekend-1-taunt":
				if (hitByPlayer) playTauntConditionalAnim();
			case "weekend-1-tauntforce":
				if (hitByPlayer) playTauntAnim();
			/*case "weekend-1-reversefakeout":
				playIdleAnim(); // TODO: Which anim?*/

			default:
				// trace('Unknown note kind: ' + event.note.kind);	
		}
		specialAnim = true;
		trace(animation.curAnim.name + '+' + noteName);
	}
}
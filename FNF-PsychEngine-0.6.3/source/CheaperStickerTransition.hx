package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;

class CheaperStickerTransition extends MusicBeatSubstate
{
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;

	var stickerShit:FlxSprite;
	public function new(isTransIn:Bool)
	{
		super();
		this.isTransIn = isTransIn;

		stickerShit = new FlxSprite(-340, -375);
		stickerShit.frames = Paths.getSparrowAtlas('transitions/sticker/cheaperStickerTransition');
		stickerShit.animation.addByPrefix('static', 'static', 26, false);
		stickerShit.animation.addByPrefix('transition', 'Transition', 26, false);

		stickerShit.scrollFactor.set(0, 0);
		add(stickerShit);

		if (isTransIn)
		{
			stickerShit.animation.play('transition', true, true, 27);
			FlxG.sound.play(Paths.sound('cheaperStickerTransition'));
			stickerShit.animation.callback = function(anim, frame, index)
			{
				if (frame == 0)
					close();
			}
		}
		else
		{
			stickerShit.animation.play('transition', true);
			FlxG.sound.play(Paths.sound('cheaperStickerTransition'));
			stickerShit.animation.callback = function(anim, frame, index)
			{
				if (finishCallback != null && frame == 27)
				{
					finishCallback();
				}
			}
		}
		/* I DONT F*CKING UNDERSTAND THIS
		SO I PUT THE STUPID INTRO THING (!isTransIn) AND IT WORKS, BUT WITH THE OTHER SHIT IT DOESNT,
		WHEN THE TRANSITION ANIM ENDS THE IMAGE FILE PUTS IN THE SCREEN 
		so i decided to put the anim in reverse and that works, i guess, i havent found an error or something with this
		but man I HATE THIS */
		if (nextCamera != null)
		{
			stickerShit.cameras = [nextCamera];
		}
		nextCamera = null;
	}

	override function update(elapsed:Float)
	{
		var width:Float = stickerShit.width;
		var height:Float = stickerShit.height;
		super.update(elapsed);
		stickerShit.setSize(width, height);
	}

	override function destroy()
	{
		if (leTween != null)
		{
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}

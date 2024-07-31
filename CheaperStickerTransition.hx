package;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class CheaperStickerTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	public static var nextCamera:FlxCamera;
	private var leTimer:FlxTimer = null;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;


	public function new(isTransIn:Bool) {
		super();
		add(PlayState.stickerTransition);
		if(!isTransIn) {
			PlayState.stickerTransition.animation.play('Intro');
			FlxG.sound.play(Paths.sound('cheaperStickerTransition'));
			leTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					PlayState.stickerTransition.animation.play('Outro');
					FlxG.sound.play(Paths.sound('cheaperStickerTransition'));
					new FlxTimer().start(0.65, function(tmr:FlxTimer)
						{
							if(finishCallback != null) {
								finishCallback();
							}
						});
				});
		}

		if(nextCamera != null) {
			PlayState.stickerTransition.cameras = [nextCamera];
		}
		nextCamera = null;
	}
}
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

typedef MenuCharacterFile = {
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var idle_anim:String;
	var confirm_anim:String;
	var confirm_offsets:Array<Int>;
	var flipX:Bool;
}

class MenuCharacter extends Character
{
	public var character:String;
	public var hasConfirmAnimation:Bool = false;
	private static var DEFAULT_CHARACTER:String = 'bf';
	public var confirmOffsets:Array<Int> = null;
	/**
	type
	0 = opponent
	1 = player
	2 = gf
	**/
	public function new(x:Float, y:Float, character:String = 'bf', type:Int)
	{
		super(x, y);

		changeCharacter(character, type);
	}

	/**
	type argument is used only for convinience
	**/
	public function changeCharacter(?character:String = 'bf', type:Int) {
		if(character == null) character = '';
		if(character == this.character) return;

		this.character = character;
		antialiasing = ClientPrefs.globalAntialiasing;
		visible = true;

		var dontPlayAnim:Bool = false;
		scale.set(1, 1);
		updateHitbox();

		hasConfirmAnimation = false;
		switch(character) {
			case '':
				visible = false;
				dontPlayAnim = true;
			default:
				var characterPath:String = 'images/menucharacters/data/' + character + '.json';
				var rawJson = null;

				#if MODS_ALLOWED
				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if(!FileSystem.exists(path)) {
					path = Paths.getPreloadPath('images/menucharacters/data/' + DEFAULT_CHARACTER + '.json');
				}
				rawJson = File.getContent(path);

				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if(!Assets.exists(path)) {
					path = Paths.getPreloadPath('images/menucharacters/data' + DEFAULT_CHARACTER + '.json');
				}
				rawJson = Assets.getText(path);
				#end
				
				var charFile:MenuCharacterFile = cast Json.parse(rawJson);
				frames = Paths.getSparrowAtlas('menucharacters/' + charFile.image);
				animation.addByPrefix('idle', charFile.idle_anim, 24);

				var confirmAnim:String = charFile.confirm_anim;
				if(confirmAnim != null && confirmAnim.length > 0 && confirmAnim != charFile.idle_anim)
				{
					animation.addByPrefix('confirm', confirmAnim, 24, false);
					if (animation.getByName('confirm') != null){ //check for invalid animation
						hasConfirmAnimation = true;
						confirmOffsets = charFile.confirm_offsets;
					}
				}

				flipX = (charFile.flipX == true);

				if(charFile.scale != 1) {
					scale.set(charFile.scale, charFile.scale);
					updateHitbox();
				}
				var init:Float = (FlxG.width * 0.25) * (1 + type) - 150;
				setPosition(init + charFile.position[0], 70 + charFile.position[1]);
				
				animation.play('idle');
		}
	}
}

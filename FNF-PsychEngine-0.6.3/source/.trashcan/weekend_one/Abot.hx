package codes.weekend_one;

import funkin.FlxAtlasSprite;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.util.FlxColor;
import codes.weekend_one.ABotAtlas;

class Abot extends FlxSprite{
    public var stereoBG:FlxSprite;
    public var eyeWhites:FlxSprite;
    public var pupil:FlxAtlasSprite;
    public var abot:FlxAtlasSprite;
    public function new(x:Float, y:Float)
    {
        super(x, y);
        stereoBG = new FlxSprite(this.x + 50, this.y + 346, 'shared:assets/shared/images/characters/abot/stereoBG');

        //eyeWhites = FlxG.bitmap.create(2, 2, FlxColor.WHITE, false, 'solid#${color.toHexString(true, false)}');
        eyeWhites = new FlxSprite(this.x - 60, this.y + 566);
        eyeWhites.makeGraphic(2, 2, FlxColor.WHITE, false, 'solid#${color.toHexString(true, false)}');
        eyeWhites.scale.set(80, 30);
        eyeWhites.updateHitbox();

        pupil = new FlxAtlasSprite(this.x - 607, this.y - 176, 'shared:assets/shared/images/characters/abot/systemEyes');

        abot = new ABotAtlas(this.x - 100, this.y + 316);
    }
}
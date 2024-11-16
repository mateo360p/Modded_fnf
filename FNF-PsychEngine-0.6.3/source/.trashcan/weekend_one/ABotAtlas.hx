package codes.weekend_one;

import flixel.math.FlxPoint;
import flixel.FlxSprite;
import funkin.FlxAtlasSprite;

using StringTools;

class ABotAtlas extends FlxAtlasSprite
{
  public function new(x:Float, y:Float)
  {
    super(x, y, 'shared:assets/shared/images/characters/abot/abotSystem', {
      FrameRate: 24.0,
      Reversed: false,
      // ?OnComplete:Void -> Void,
      ShowPivot: false,
      Antialiasing: true,
      ScrollFactor: new FlxPoint(1, 1),
    });
  }
}
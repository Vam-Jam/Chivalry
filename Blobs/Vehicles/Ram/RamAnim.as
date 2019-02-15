void onInit(CSprite@ this)
{
	ReloadSprites(this);
}

void ReloadSprites(CSprite@ sprite)
{
	string filename = sprite.getFilename();

	sprite.SetZ(-10.0f);

	sprite.addSpriteLayer("arm", "RamWeapon.png", 60, 16);
	
	/*CSpriteLayer@ front = sprite.addSpriteLayer("front layer", sprite.getConsts().filename, 60, 38);
	if (front !is null)
	{
		front.addAnimation("cover", 0, false);
		int[] frames = { 3, 4, 5 };
		front.animation.AddFrames(frames);
		front.SetRelativeZ(20.0f);
		front.SetOffset(Vec2f(0,-6));
	}*/

}

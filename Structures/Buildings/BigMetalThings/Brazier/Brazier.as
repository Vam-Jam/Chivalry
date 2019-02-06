//Made by vamist

void onInit(CSprite@ this)
{
	this.SetAnimation("default");// sets default animation
}	

void onInit(CBlob@ this)
{
	this.addCommandID("LightUp");//good name
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() == this.getTeamNum())//ToDo : Check for Oil
	{
		CBitStream params;
		caller.CreateGenericButton("$change_class$", Vec2f(10, 0), this, this.getCommandID("LightUp"), getTranslatedString("Light"), params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("LightUp"))
	{
		this.getSprite().SetAnimation("lit");
	}
}

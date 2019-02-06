//Made by vamist

const int BurnTime       = 15; 	 // How long it takes in seconds to make oil
const int WoodCostPerUse = 300;  // How much wood is required to make oil
const int OilOutput      = 100;	 // How much oil you get from burning wood
const int MaxOilStored   = 300;  // Max oil accepted limit
const int MaxWoodStored  = 300;  // Max wood accepted limit


void onInit(CBlob@ this)
{
	//Animation stuff
	this.getSprite().SetAnimation("default");

	//Commands
	this.addCommandID("NowLetThereBeLight");
	this.addCommandID("OutputOilBucket");
	this.addCommandID("AddBucket");
	this.addCommandID("AddWood");

	//Oil props
	this.set_u16("OilStored",0);  // How much oil we currently have
	this.set_u16("WoodStored",0); // How much wood we currently have
	this.set_u16("BucketCount",0);// How much buckets we currently have
	this.set_u16("ProcessTime",0);// How long have we processed this wood for?
	this.set_bool("Active",false);// Are we currently active (no, i've just been made)
}

void onTick(CBlob@ this)
{
	if(getNet().isServer())//Do server side only (so we just need to sync (or cmd))
	{
		if(this.get_bool("Active"))
		{
			if(getGameTime() % 30 == 0){
				this.add_u16("ProcessTime",1);
			}

			if(this.get_u16("ProcessTime") >= BurnTime){
				this.SendCommand(this.getCommandID("OutputOilBucket"));
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	if(this.get_bool("Active")){return;}
	
	if(caller.getTeamNum() == this.getTeamNum())
	{
		//Bucket request
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$change_class$", Vec2f(-5, 0), this, 
				this.getCommandID("AddBucket"), getTranslatedString("Hold oil using a bucket"), params);
		}

		//Wood request
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$change_class$", Vec2f(5, 0), this, 
				this.getCommandID("AddWood"), getTranslatedString("Add "+WoodCostPerUse+" wood to start making oil"), params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	//TODO make switch instead of if
	//Not possible, AS only accepts const as a num

	if(cmd == this.getCommandID("NowLetThereBeLight"))
	{
		this.set_bool("Active",true);
		this.getSprite().SetAnimation("lit");
	}
	else if(cmd == this.getCommandID("AddBucket"))
	{
		if(isClient()){return;}

		u16 blobNum = 0;
		if(!params.saferead_u16(blobNum)){
			warn("AddBucket");
			return;
		}

		CBlob@ blob = getBlobByNetworkID(blobNum);
		if(blob is null){return;}

		CBlob@ attachedBlob = blob.getAttachments().getAttachedBlob("PICKUP");
		if(attachedBlob is null){return;}

		if(attachedBlob.getName() == "bucket")
		{
			attachedBlob.server_Die();
			this.add_u16("BucketCount",1);
		}

		checkIfActive(this);
	}
	else if(cmd == this.getCommandID("AddWood"))
	{
		if(isClient()){return;}

		u16 blobNum = 0;
		if(!params.saferead_u16(blobNum)){
			warn("AddWoodBlobReadFail");
			return;
		}

		CBlob@ blob = getBlobByNetworkID(blobNum);
		if(blob is null){
			warn("AddWoodBlobNull");
			return;
		} 

		CInventory@ invo = blob.getInventory();
		int woodCount = invo.getCount("mat_wood");


		if(woodCount >= WoodCostPerUse)
		{
			invo.server_RemoveItems("mat_wood", WoodCostPerUse);
			this.add_u16("WoodStored",			WoodCostPerUse);
		}
		checkIfActive(this);
	}
	else if(cmd == this.getCommandID("OutputOilBucket"))
	{

		this.set_bool("Active",false);
		this.getSprite().SetAnimation("default");
		if(isClient()){return;}

		this.sub_u16("WoodStored", WoodCostPerUse);
		this.sub_u16("BucketCount",1);
		this.set_u16("ProcessTime",0);
		server_CreateBlob("bucket", this.getTeamNum(), this.getPosition());
	}
}


void checkIfActive(CBlob@ this)
{
	if(this.get_bool("Active")){return;}
	if(this.get_u16("BucketCount") > 0 && this.get_u16("WoodStored") >= WoodCostPerUse){
		this.SendCommand(this.getCommandID("NowLetThereBeLight"));
	}
}
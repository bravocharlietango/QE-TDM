/*----------------------------------------------------------------------
originally idglobe.qc by stan smith (stoshsmith@worldnet.att.net) - 23 August 1996
cleaned up and modified by angrypunk for qetdm - 11/4/2021

in tdm/defs.qc:

.float player_id_inuse;		// is player id on?  1=yes 0=no
.float player_id_time;		// time until next id unless re-aimed
.entity player_id_ent;		// last entity ID'ed'

in weapons.qc:

 	if(self.impulse==15)
 		ID_toggle();

use impulse 15 to toggle
----------------------------------------------------------------------*/

void() player_id_aim =
{
	local vector src;
	local entity me;
	local float temp;

	me=self.owner;
	if(!me.player_id_inuse)
	{
		remove(self);
		return;
	}

	// setup our traceline
	makevectors(me.v_angle);
	src=me.origin+v_forward*10;
	src_z=me.absmin_z+me.size_z*0.7;

	traceline(src,src+v_forward*2048,FALSE,me);
	setorigin(self,trace_endpos-v_forward*10);
	// end traceline stuff

	self.nextthink=time+0.1;

	if(me.player_id_ent!=trace_ent||time>me.player_id_time)
	{
		if(trace_ent.classname=="player")
		{
			// print friend or enemy
			if(trace_ent.team!=me.team) { sprint(me,"ENEMY: "); }
			else { sprint(me,"FRIEND: "); }

			// print player name
			sprint(me,trace_ent.netname);

			// get targets weapon
			temp=trace_ent.weapon;

			// print current weapon of target
			if(temp==IT_AXE) 
			{ sprint(me,"- Axe"); }

			else if(temp==IT_SHOTGUN) 
			{ sprint(me,"- Shotgun"); }

			else if(temp==IT_SUPER_SHOTGUN)  
			{ sprint(me,"- Super Shotgun"); }

			else if(temp==IT_NAILGUN)  
			{ sprint(me,"- Nailgun"); }

			else if(temp==IT_SUPER_NAILGUN) 
			{ sprint(me,"- Super Nailgun"); }

			else if(temp==IT_GRENADE_LAUNCHER)  
			{ sprint(me,"- Grenade Launcher"); }

			else if(temp==IT_ROCKET_LAUNCHER) 
			{ sprint(me,"- Rocket Launcher"); }

			else if(temp==IT_LIGHTNING) 
			{ sprint(me,"- Lightning Gun"); }

			else 
			{ sprint(me,"- Unknown Weapon"); }
		}
		else
		{
			// not targetting player
			return;
		}

		sprint(me,"\n");
		me.player_id_time=time+3;
		me.player_id_ent=trace_ent;
	}
}

void() player_id_toggle =
{
	local entity temp;

	if(self.player_id_inuse)
	{
		self.player_id_inuse=0;
	}
	else
	{
		self.player_id_inuse=1;
		temp=spawn();
		setorigin(temp,self.origin);
		setsize(temp,'0 0 0','0 0 0');
		temp.classname="player_id";

		temp.movetype=MOVETYPE_NONE;
		temp.solid=SOLID_NOT;
		temp.owner=self;
		temp.nextthink=time+0.1;
		temp.think=player_id_aim;
	}
}

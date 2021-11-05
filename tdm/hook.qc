//====================================================================
//
// GRAPPLING HOOK			by: Perecli Manole AKA Bort
//
//====================================================================
// Aside from this new file, the following are the modifications
// done to id's original source files:
//--------------------------------------------------------------------
// File: Progs.src
// Location: before the "weapons.qc" line
// Added: hook.qc
//--------------------------------------------------------------------
// File: Weapons.qc
// Procedure: ImpulseCommands
// Location: in the beginning of the function
// Added: CheckGrapHook ();
//--------------------------------------------------------------------
// File: World.qc
// Procedure: worldspawn
// Location: after line "precache_model ("progs/s_spike.mdl");"
// Added: precache_model ("progs/hook.mdl");
//        precache_model ("progs/bit.mdl");
//--------------------------------------------------------------------
// File: Weapons.qc
// Procedure: W_Precache
// Location: end of procedure
// Added: precache_sound ("shambler/smack.wav");
//        precache_sound ("blob/land1.wav");
//--------------------------------------------------------------------
// File: Defs.qc
// Declaration group: player only fields
// Location: after line ".float pain_finished;"
// Added: .float hook;	
//--------------------------------------------------------------------


void(vector org, vector vel, float damage) SpawnBlood;	// prototype
float () crandom;   							// prototype


float	HOOK_OUT = 1;		// is hook currently extended? (bit flag)
float	HOOK_ON = 2;		// is ACTIVATE_HOOK impulse on? (bit flag)
float ACTIVATE_HOOK = 98;	// impulse constant
float	TERMINATE_HOOK = 97;    // impulse constant


//--------------------------------------------------------------------
// Removes hook and detaches player
//--------------------------------------------------------------------
void () DropHook =
{
      local entity linkptr;
      local entity nextptr;

	// removes flag of hook instance being present
	self.owner.hook = self.owner.hook - (self.owner.hook & HOOK_OUT);
        
	// removes chain
	linkptr = self.goalentity;
	while (linkptr != world)
	{
		nextptr = linkptr.goalentity;
		remove (linkptr);
		linkptr = nextptr;
	}
	
	// removes hook
	remove (self);
};


//--------------------------------------------------------------------
// Updated calculation of link positions
//--------------------------------------------------------------------
void () LinkPos =
{
	setorigin (self, self.owner.origin + ((self.enemy.origin + '0 0 16') - self.owner.origin) * self.weapon);
	self.nextthink = time + 0.01;
};


//--------------------------------------------------------------------
// Creates chain
//--------------------------------------------------------------------
entity (entity head, entity tail, float num) CreateChain =
{
	local entity link, prevlink;
	local float linknum;

	linknum = num;
	num = num + 1;
	prevlink = world;
	while (linknum > 0)
	{
		link = spawn();
		link.goalentity = prevlink;
		prevlink = link;
		link.owner = head;
		link.enemy = tail;
		link.weapon = linknum / num;
		link.movetype = MOVETYPE_NOCLIP;
		link.solid = SOLID_NOT;
		link.angles_z = 51 * linknum;
		link.angles_y = 41 * linknum;
		link.angles_x = 31 * linknum;
		link.avelocity = '310 410 510';
		setmodel (link, "progs/spike.mdl");
		setsize (link, '0 0 0', '0 0 0');
		setorigin (link, head.origin + ((tail.origin + '0 0 16') - head.origin) * link.weapon);
		link.nextthink = time + 0.01;
		link.think = LinkPos;
		linknum = linknum - 1;
	}
	return link;
};


//--------------------------------------------------------------------
// Hook pulls player function
//--------------------------------------------------------------------
void () HookPull =
{
        local vector vel, spray;
        local float v;

	if ( 	((self.owner.hook & HOOK_ON) != HOOK_ON) || 
		(self.owner.teleport_time > time) || 
		(self.owner.deadflag) ||			// if player dies
		(self.enemy.solid == SOLID_NOT)	)	// if target dies
	{
		DropHook();
		return;
	}
	
	if (self.enemy.takedamage)
		T_Damage (self.enemy, self, self.owner, 3);

	if (self.enemy.solid == SOLID_SLIDEBOX)
	{
		sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);
		spray_x = 100 * crandom();
 		spray_y = 100 * crandom();
		spray_z = 100 * crandom() + 50;
		SpawnBlood (self.origin, spray, 20);
		setorigin (self, self.enemy.origin + self.enemy.mins + self.enemy.size * 0.5);
	}

	self.velocity = self.enemy.velocity;
		
	vel = self.origin - (self.owner.origin + '0 0 16');
	v = vlen (vel);
	if (v <= 100)
		vel = normalize(vel) * v * 7;  
	if ( v > 100 )
		vel = normalize(vel) * 700;  
	self.owner.velocity = vel;
	self.nextthink = time + 0.1;

};


//--------------------------------------------------------------------
// Star's touch function
//--------------------------------------------------------------------
void() ChainTouch =
{
	if ((self.owner.hook & HOOK_ON) != HOOK_ON)
	{
		DropHook();
		return;
	}

	if (other.takedamage)
		T_Damage (other, self, self.owner, 10 );

 	if (other.solid == SOLID_SLIDEBOX)
	{
		sound (self, CHAN_WEAPON, "shambler/smack.wav", 1, ATTN_NORM);	
		SpawnBlood (self.origin, self.velocity, 10);
		setorigin (self, other.origin + other.mins + other.size * 0.5);
	}
	else
	{
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		self.avelocity = '0 0 0';
	}

	self.velocity = other.velocity;

	self.enemy = other;
	self.nextthink = time + 0.1;
	self.think = HookPull;
	self.touch = SUB_Null;
};


//--------------------------------------------------------------------
// Initiates the hook
//--------------------------------------------------------------------
void(entity myself) InitiateHook =
{
	local entity newhook;

	newhook = spawn ();
	newhook.owner = myself;
	newhook.movetype = MOVETYPE_FLY;
	newhook.solid = SOLID_BBOX;
	setmodel (newhook, "progs/spike.mdl");
	setsize (newhook, '0 0 0', '0 0 0');     
	makevectors (myself.v_angle);
	setorigin (newhook, myself.origin + (v_forward*16) + '0 0 16' );
	newhook.velocity = v_forward*1000;
	newhook.angles = vectoangles(newhook.velocity);
	newhook.avelocity = '0 0 600';
	sound (myself, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
	
	newhook.touch = ChainTouch;
	newhook.nextthink = time + 0.7;     // reach length of grappling hook
	newhook.think = DropHook;
	newhook.goalentity = CreateChain (newhook, myself, 8);
};


//--------------------------------------------------------------------
// Checks impulse
//--------------------------------------------------------------------
void() CheckGrapHook = 
{
	if (((self.hook & HOOK_OUT) != HOOK_OUT))
	{
		// flags that one instance of hook is spawned
		self.hook = self.hook | HOOK_OUT;
	
		// flags last activated hook impulse as being ON 
		self.hook = self.hook | HOOK_ON;   

		InitiateHook (self);
		return;
	}

	if (((self.hook & HOOK_OUT) == HOOK_OUT))
	{
		// flags last activated hook impulse as being OFF
		self.hook = self.hook - (self.hook & HOOK_ON);
		
		return;
	}
}; 
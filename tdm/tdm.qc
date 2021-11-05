float last_leader;
float current_leader;

float	intermission_running;
float	intermission_exittime;

void StartItem();

//const string SOUND_WIN = "boss2/pop2.wav";
//const string SOUND_LOSE = "boss1/pain.wav";


float(string name) tdm_getBotTeam =
{
    if(name == "[BOT] Azizam"
    || name == "[BOT] Bitterman"
    || name == "[BOT] Crapshoot"
    || name == "[BOT] Mr.Elusive"
    )
        return TEAM_RED;

    else if(name == "[BOT] Barney"
    || name == "[BOT] ClockParadox"
    || name == "[BOT] Demona"
    || name == "[BOT] FloridaMan")

        return TEAM_BLUE;

    return TEAM_ALL;
}

float(entity ent) tdm_isBot =
{
    if(ent.flags & FL_ISBOT)
        return TRUE;

    return tdm_getBotTeam(ent.netname) != TEAM_ALL;
}

float(float team) tdm_game_getTeamScore =
{
	local float team_score = 0;
	return	team_score = team == TEAM_BLUE ? score_blue : score_red;
}

void(entity player) tdm_player_autoAssignTeam =
{
	// Handle bots
	if(tdm_isBot(player))
	{
		player.team = tdm_getBotTeam(player.netname);
		return;
	}

    local float countBlue = 0;
	local float countRed = 0;
	local entity p = world;
	while((p = findPlayer(p)))
	{
		if(p.team == TEAM_BLUE)
			countBlue++;
		else if(p.team == TEAM_RED)
			countRed++;
	}
    
    player.team = countBlue <= countRed ? TEAM_BLUE : TEAM_RED;
	
}

float(entity player) tdm_player_checkTeam =
{
	return player.team;
}

void(entity player) tdm_player_changeTeam =
{
	if (player.team == TEAM_BLUE) { player.team = TEAM_RED; }
	else if (player.team == TEAM_RED) { player.team = TEAM_BLUE; }
}

float() tdm_game_checkTeamBalance =
{
    local float countBlue = 0;
	local float countRed = 0;
	local entity p = world;
	while((p = findPlayer(p)))
	{
		if(p.team == TEAM_BLUE)
			countBlue++;
		else if(p.team == TEAM_RED)
			countRed++;
	}
	
	// return which team is behind in player count or if they are tied
	if (countBlue < countRed) { return TEAM_BLUE; }
	if (countBlue > countRed) { return TEAM_RED; }
	if (countBlue == countRed) { return TEAMS_BALANCED; }

	return FALSE;	
}

void(entity player) tdm_player_checkChangeTeam =
{
	if (self.impulse == 152) 
	{ 
		local float checkBalance = tdm_game_checkTeamBalance();

      	local entity p = world;
		local float otherTeam = self.team == TEAM_BLUE ? TEAM_RED : TEAM_BLUE;
		local string newColor = self.team == TEAM_BLUE ? "RED" : "BLUE";

		if (checkBalance == otherTeam)  
		{ 
			tdm_player_changeTeam(player); 

			while((p = findPlayerInTeam(self.team,p)))
      		{
          		centerprint4(p,player.netname," has switched to the ",newColor," team\n");
      		}
    
      		while((p = findPlayerInTeam(otherTeam,p) && p != other))
      		{
      	  		centerprint4(p,player.netname," has switched to the ",newColor," team\n");
      		}
		}
		else {centerprint(self,"You can't change teams right now");}
	}
}

void() tdm_game_autoBalanceTeams =
{
    local float countBlue = 0;
	local float countRed = 0;
	local entity p = world;
	while((p = findPlayer(p)))
	{
		if(p.team == TEAM_BLUE)
			countBlue++;
		else if(p.team == TEAM_RED)
			countRed++;
	}

	// red team is out of balance, move player with least frags
	if (countRed + 2 < countBlue) { 

	}

	// blue tream is out of balance, move player with least frags
	if (countBlue +2 < countRed) {

	}
}

void() tdm_game_displayLeaderChange =
{
    local entity p = world;
	local float otherTeam = self.team == TEAM_BLUE ? TEAM_RED : TEAM_BLUE;

      while((p = findPlayerInTeam(self.team,p)))
      {
        centerprint(p,"Your team has taken the lead\n");
      }
    
      while((p = findPlayerInTeam(otherTeam,p) && p != other))
      {
        centerprint(p,"Your team has lost the lead\n");
      }
}

void() tdm_game_checkLeaderChange =
{
	local float otherTeam = self.team == TEAM_BLUE ? TEAM_RED : TEAM_BLUE;
	local float team_score = tdm_game_getTeamScore(self.team);
	local float enemy_score = tdm_game_getTeamScore(otherTeam);

	if (team_score > enemy_score) { current_leader = self.team == TEAM_BLUE ? TEAM_BLUE : TEAM_RED ;}
	if (current_leader != last_leader) 	{ tdm_game_displayLeaderChange(); } 

	last_leader = current_leader;
}

void() tdm_game_displayScore =
{
    local entity p = world;
    local float team_score = 0;
	local float enemy_score = 0;
	local float otherTeam = self.team == TEAM_BLUE ? TEAM_RED : TEAM_BLUE;

	team_score = tdm_game_getTeamScore(self.team);
    enemy_score = tdm_game_getTeamScore(otherTeam);
		
	local float is_leading = 0;
	if (team_score >= enemy_score) { is_leading = 1; }
	else { is_leading = 0; }

	if (is_leading == 1){
		centerprint5(self,"Your team is leading with ",ftos(team_score)," frags\nYou need ", ftos(tdm_fraglimit - team_score)," more frags to win");
	}
	else {
		centerprint5(self,"Your team is behind with ",ftos(team_score)," frags\nYou need ", ftos(tdm_fraglimit - team_score)," more frags to win");
	}
}

void(entity player) tdm_player_checkKillStreak =
{
    local entity p = world;
	local float kill_streak;
	kill_streak = player.frags - player.prev_frags;

    if (kill_streak == 3 && player.netname != last_spree){ 
        last_spree = player.netname;
		player.is_onSpree = 1;
		while((p = findPlayer(p))) { centerprint2(p,player.netname," is on a killing spree!\n"); }  
    }	
    else if (kill_streak == 6 && player.netname != last_spree) {	
        last_spree = player.netname;
        while((p = findPlayer(p))) { centerprint2(p,player.netname," is on a killing frenzy!\n"); } 
	}	
    else if (kill_streak == 9 && player.netname != last_spree) {
	  	last_spree = player.netname;
	  	while((p = findPlayer(p))) { centerprint2(p,player.netname," is on a killing rampage!\n"); }
	}
    else if (kill_streak == 12 && player.netname != last_spree) {
	  	last_spree = player.netname;
	  	while((p = findPlayer(p))) { centerprint2(p,player.netname," is unstoppable!\n"); }
	}
}

void(entity attacker, entity targ) tdm_player_endsKillingSpree =
{
    local entity p = world;
    while((p = findPlayer(p))) 
    {
        centerprint4(p,attacker.netname," ended ", targ.netname,"'s killing spree.\n"); 
    }
}

float() tdm_game_getFragsLeft =
{
    local entity p = world;
    local float team_score = 0;
	local float enemy_score = 0;
	
	local float otherTeam = self.team == TEAM_BLUE ? TEAM_RED : TEAM_BLUE;

	team_score = tdm_game_getTeamScore(self.team);
    enemy_score = tdm_game_getTeamScore(otherTeam);
		
	local float is_leading = 0;
	if (team_score >= enemy_score) { is_leading = 1; }
	else { is_leading = 0; }

	if (is_leading == 1){ return (tdm_fraglimit - team_score);}
	else {return (tdm_fraglimit - enemy_score);}
}

entity(float team) tdm_player_highestScoreOnTeam =
{
    local entity p = world;
	local entity player;
	local float high_score;

	while((p = findPlayerInTeam(team,p))) {
      	if (p.frags > high_score)
            {
              	player = p;
          	}
      }

	return player;
}

float() tdm_player_highScore =
{
    local entity p = world;
	local float high_score = 0;

	while((p = findPlayer(p))) {
      	if (p.frags > high_score)
            {
              	high_score = p.frags;
          	}
      }

	return high_score;
}

void(entity player) tdm_game_addBot = 
{
	bprint("Adding bot player"); 
	localcmd("addbot\n");
}

void(entity player) tdm_game_kickBot =
{
	localcmd("kickbot\n");
}

void(entity player) tdm_player_checkImpulse =
{
	if(player.impulse == 152) { tdm_player_checkChangeTeam(player);}
	if(player.impulse == 153) { tdm_game_addBot(player);}
	if(player.impulse == 154) { tdm_game_kickBot(player);}
}

void(float team) tdm_game_incTeamScore =
{
	if ((team == TEAM_RED)) { score_red = score_red + 1 ;}
	else if ((team == TEAM_BLUE)) { score_blue = score_blue + 1;}
}

void(float team) tdm_game_decTeamScore =
{
	if ((team == TEAM_RED)) { score_red = score_red - 1 ;}
	else if ((team == TEAM_BLUE)) { score_blue = score_blue - 1 ;}
}

void() tdm_game_displayGameOver = 
{
    local entity p = world;

	local float blue_score = tdm_game_getTeamScore(TEAM_BLUE);	
	local float red_score = tdm_game_getTeamScore(TEAM_RED);

	blue_score = tdm_game_getTeamScore(TEAM_BLUE);
	red_score = tdm_game_getTeamScore(TEAM_RED);

	local entity blue_mvp = tdm_player_highestScoreOnTeam(TEAM_BLUE);
	local entity red_mvp = tdm_player_highestScoreOnTeam(TEAM_RED);

	if (blue_score > red_score)
	{
	      while((p = findPlayer(p)))
	      {
	        centerprint7(p,"BLUE team won the match with ", ftos(blue_score)," frags.\n\nBLUE Team MVP: ", blue_mvp.netname , "\n\nRED Team MVP: ," , red_mvp.netname , "\n");
	      }
	}

	else if (blue_score < red_score)
	{
	      while((p = findPlayer(p)))
	      {
	        centerprint7(p,"RED team won the match with ", ftos(red_score)," frags.\n\nRED Team MVP: ", red_mvp.netname , "\n\nBLUE Team MVP: ," , blue_mvp.netname , "\n");  
	      }
	}

	else if (blue_score == red_score)
	{
	      while((p = findPlayer(p)))
	      {
	        centerprint7(p,"BLUE and RED teams tied the match with ", ftos(blue_score), " frags.\n\nBLUE Team MVP: ", blue_mvp.netname , "\n\nRED Team MVP: ," , red_mvp.netname , "\n");
	      }
	}	
}
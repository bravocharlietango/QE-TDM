void() Entmod_Command_Activate =
{
    entmod.active = TRUE;
    entmod.mode = ENTMOD_MODE_NONE;


    sprint(self,"Entmod activated\n");
    self.weapon = IT_SHOTGUN;
}

void() Entmod_Command_Deactivate =
{
    entmod.active = FALSE;
    sprint(self,"Entmod deactivated\n");
}

void() Entmod_Command_PrintEntity =
{
    if(!entmod.selectedEntity)
        return Entmod_Error_NoEntitySelected();
    
    eprint(entmod.selectedEntity);
}


void() Entmod_Command_GrabEntity =
{
    if(!entmod.selectedEntity)
        return Entmod_Error_NoEntitySelected();

    if(entmod.mode == ENTMOD_MODE_NONE) {
        entmod.mode = ENTMOD_MODE_MOVING;
        sprint(self,"Started moving entity\n");

        entmod.moverStartOrigin = self.origin;
        entmod.moveeStartOrigin = entmod.selectedEntity.origin;
    } 
    else if(entmod.mode == ENTMOD_MODE_MOVING) {
        entmod.mode = ENTMOD_MODE_NONE;
        sprint(self,"Stopped moving entity\n");
    }
    else {
        sprint(self,"Invalid mode\n");
    }
}

void() Entmod_Command_Copy =
{
    if(!entmod.selectedEntity)
        return Entmod_Error_NoEntitySelected();

    
    local string targetClass = entmod.selectedEntity.classname;
    if(targetClass == "func_wall" || targetClass == "func_plat" || targetClass == "func_door" || targetClass == "func_button")
    {
        local entity newEnt = spawn();
        newEnt.origin = entmod.selectedEntity.origin;
        newEnt.model = entmod.selectedEntity.model;
        newEnt.classname = "func_wall";

        local entity oself = self;
        self = newEnt;
        func_wall();
        self = oself;

        entmod.selectedEntity = newEnt;

        sprint(self,"Entity copied into func_wall\n");
    }
}


void() Entmod_HandleCommand =
{
    // Only the host can do it
    if(self != find(world,classname,"player"))
        return;

    if(!entmod.active)
    {
        Entmod_Command_Activate();
        return;
    }

    if(cvar("scratch1") == 0)
    {
        Entmod_Command_Deactivate();
    }
    else if(cvar("scratch1") == 1)
    {
        Entmod_Command_PrintEntity();
    }
    else if(cvar("scratch1") == 2)
    {
        Entmod_Command_Copy();
        /*
        if(!entmod_selectedEntity) {
            dprint("No entity selected\n");
            return;
        }

        dprint("Copied entity\n");

        local entity ent = spawn();
        ent.origin = entmod_selectedEntity.origin;
        ent.model = entmod_selectedEntity.model;
        ent.classname = "func_wall";

        local entity oself = self;
        self = ent;
        func_wall();
        self = oself;
        */
    }
    else if(cvar("scratch1") == 3)
    {
        Entmod_Command_GrabEntity();
    }
}
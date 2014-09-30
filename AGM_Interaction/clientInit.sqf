// by commy2 and CAA-Picard

if (!hasInterface) exitWith {};

AGM_Interaction_isOpeningDoor = false;
AGM_Interaction_currentInventory = objNull;
AGM_Dancing = false;

addMissionEventHandler ["Draw3D", {
  if !(profileNamespace getVariable ["AGM_showPlayerNames", true]) exitWith {};

  if (profileNamespace getVariable ["AGM_showPlayerNamesOnlyOnCursor", true]) then {

    _target = cursorTarget;
    _target = if (_target in allUnitsUAV) then {objNull} else {effectiveCommander _target};

    if (!isNull _target && {side group _target == playerSide} && {_target != player}) then {
      _distance = player distance _target;
      _alpha = ((1 - 0.2 * (_distance - AGM_Interaction_PlayerNamesViewDistance)) min 1) * AGM_Interaction_PlayerNamesMaxAlpha;
      [_target, _alpha, _distance * 0.026] call AGM_Interaction_fnc_drawNameTagIcon;
    };

  } else {

    _pos = positionCameraToWorld [0, 0, 0];
    _targets = _pos nearObjects ["Man", AGM_Interaction_PlayerNamesViewDistance + 5];

    if (!surfaceIsWater _pos) then {
      _pos = ATLtoASL _pos;
    };
    _pos2 = positionCameraToWorld [0, 0, 1];
    if (!surfaceIsWater _pos2) then {
      _pos2 = ATLtoASL _pos2;
    };
    _vecy = _pos2 vectorDiff _pos;

    {
      _target = if (_x in allUnitsUAV) then {objNull} else {effectiveCommander _x};

      if (!isNull _target && {side group _target == playerSide} && {_target != player}) then {
        _relPos = (visiblePositionASL _target) vectorDiff _pos;
        _distance = vectorMagnitude _relPos;
        _projDist = _relPos vectorDistance (_vecy vectorMultiply (_relPos vectorDotProduct _vecy));

        _alpha = ((1 - 0.2 * (_distance - AGM_Interaction_PlayerNamesViewDistance)) min (1 - 0.15 * (_projDist * 5 - _distance - 3)) min 1) * AGM_Interaction_PlayerNamesMaxAlpha;

        // Check if there is line of sight
        if (_alpha > 0) then {
          if (lineIntersects [_pos, (visiblePositionASL _target) vectorAdd [0,0,1], vehicle player, _target]) then {
            _alpha = 0;
          };
        };
        [_target, _alpha, _distance * 0.026] call AGM_Interaction_fnc_drawNameTagIcon;
      };
    } forEach _targets;

  };
}];

// restore global fire teams for JIP
{
  _team = _x getVariable ["AGM_assignedFireTeam", ""];
  if (_team != "") then {_x assignTeam _team};
} forEach allUnits;


player addEventHandler ["InventoryOpened", {
  
  private ["_curTarget", "_override"];
  
  _curTarget = cursorTarget;
  AGM_Interaction_currentInventory = (_this select 1);
  _override = false;
  
  if ((_curTarget == AGM_Interaction_currentInventory) && (AGM_Interaction_currentInventory getVariable ["AGM_LockedInventory", false]) && (alive AGM_Interaction_currentInventory)) then {
    // a box or similar
    _override = true;
    hint (localize "STR_AGM_Interaction_InventoryLocked");
  };
  
  if ((backpackContainer _curTarget == AGM_Interaction_currentInventory) && (_curTarget getVariable ["AGM_LockedInventory", false]) && (alive _curTarget) && !(_curTarget getVariable ['AGM_Unconscious', false])) then {
    // a unit's backpack
    _override = true;
    hint format [(localize "STR_AGM_Interaction_BackpackLocked"), name _curTarget];
  };
  
  _override
}];
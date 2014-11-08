// by commy2

private ["_unit", "_launcher", "_config"];

_unit = _this select 0;
_launcher = _this select 2;

_config = configFile >> "CfgWeapons" >> _launcher;

if (isClass _config && {getText (_config >> "AGM_UsedTube") != ""} && {count secondaryWeaponMagazine _unit == 0}) then {
	private "_magazine";

	_magazine = getArray (_config >> "magazines") select 0;

	if (backpack _unit == "") then {
		_unit addBackpack "Bag_Base";

		_unit addMagazine _magazine;
		_unit addWeapon _launcher;

		removeBackpack _unit;
	} else {
		_unit addMagazine _magazine;
		_unit addWeapon _launcher;
	};
};

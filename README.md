# HWRTools
 Tools for HWR

Adds the following console commands

k_skills  - Unlock all skills for the current character

k_blacksmith - Unlock all Blacksmith Upgrades for current character

k_magic - Unlock all Magicshop Upgrades for current character

k_potion - Unlock all Potion Upgrades for current character

k_town_buildings - Unlock all Town Buildings for current town, to highest level

k_flags - Unlock all relevant flags for Current Town

k_blueprints - Unlock all Blueprints for Current Town

k_attunements - Unlock all Attunements for current character

k_remove_blueprints - removes blueprints and attunements

k_remove_attunements - removes attunements

k_town - sets town flags and unlocks all buildings + blueprints

k_char - gives all skills, attunements and upgrades to current character

k_all - does both k_town and k_char in one command

k_reset_char - remove all upgrades from character

k_reset_town - reset town buildings to default state

refresh - refresh current town. 

refresh_modifiers - refreshes player modifiers

set_char_level \<int\> - sets character level to int

next_act - changes level to next act, similar to next_level

go_to_floor  \<int\> - changes level to specified floor

go_to_act  \<int\> - changes level to beginning of specified act

give_blueprints \<int\> - gives \<int\> amount of blueprints at random
 
give_blood_rite \<id\> \<amount\> - gives bloodrites (check the wiki link below for blood rite id's)

old_gladiator \<id\> \<amount\> - adds sword stacks at the old gladiator e.g "old_gladiator attack-power 50"
 
fountain_deposit \<amount\> - deposits amount straight from your town money into the fountain

change_class \<class name\> - change class during gameplay

spawn_unit \<id\> \<amount\> - spawns a unit, eg "spawn_unit actors/archer_1.unit 10"

spawn_prefab \<id\> - spawns a prefab, eg "spawn_prefab prefabs/special/special_item_gambler.pfb"

soundtest - Opens Soundtest Menu (based on @Varna's work, many thanks)

F1 - Unit Spawn Menu, amount can't be specified in the same way it can with the console command, but list can be searched/filtered.

F2 - Prefab Spawn Menu, same as above.


soundtest is a console command rather than a button as i figured it would probably be less commonly used, and it means i can easily avoid using F3 and clashing with the popular Trainer Mod.

https://github.com/KellyFromSales/HWRTools/wiki/Blood-Rites-command

https://github.com/KellyFromSales/HWRTools

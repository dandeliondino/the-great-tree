

EXTERNAL emit_signal(signalName)
EXTERNAL inventory_count(item_id)
EXTERNAL add_item(item_id, quantity)
EXTERNAL remove_item(item_id, quantity)
EXTERNAL disable_instance()
EXTERNAL journal_updated()
EXTERNAL emit_entity_state_changed(entity_name, canInteract, isQuestTarget)
EXTERNAL change_level(level_name)
EXTERNAL get_current_level()

LIST InteractionStates = disabled=0, enabled
LIST Quests = firequest, treequest

LIST npcquest_steps = talkToNPC, giveNPCItem

LIST firequest_steps = forestIsOnFire, fireIsOut, tellAnimalsFireIsOut
LIST treequest_steps = treeAtRisk, treeIsBurned, treeNeedsMagic, treeNeedsRegrowthRune, regrowthRunePlaced, waitUntilTomorrow, treeIsRegrown



VAR towerdoor_entity = (enabled)
VAR animal1_entity = (enabled)
VAR animal2_entity = (enabled)
VAR animal3_entity = (enabled)
VAR greattree_entity = (disabled)
VAR greattreerestored_entity = (enabled)
VAR bucket_entity = (enabled)
VAR stream_entity = (enabled)
VAR forestfire_entity = (enabled)
VAR bookshelf_entity = (enabled)
VAR charredwood_entity = (disabled)
VAR bed_entity = (enabled)
VAR signpost_toforest_entity = (enabled)
VAR signpost_togreattree_entity = (enabled)

VAR TowerDayOne = "TowerDayOne"
VAR ForestDayOne = "ForestDayOne"
VAR GreatTreeDayOne = "GreatTreeDayOne"
VAR TowerDayTwo = "TowerDayTwo"
VAR ForestDayTwo = "ForestDayTwo"
VAR GreatTreeDayTwo = "GreatTreeDayTwo"

-> gameloop


== setup ==
~ entity_state_changed("towerdoor", towerdoor_entity)
~ entity_state_changed("animal1", animal1_entity)
~ entity_state_changed("animal2", animal2_entity)
~ entity_state_changed("animal3", animal3_entity)
~ entity_state_changed("greattree", greattree_entity)
~ entity_state_changed("greattreerestored", greattreerestored_entity)
~ entity_state_changed("bucket", bucket_entity)
~ entity_state_changed("stream", stream_entity)
~ entity_state_changed("forestfire", forestfire_entity)
~ entity_state_changed("bookshelf", bookshelf_entity)
~ entity_state_changed("charredwood", charredwood_entity)
~ entity_state_changed("bed", bed_entity)
~ entity_state_changed("signpost_toforest", signpost_toforest_entity)
~ entity_state_changed("signpost_togreattree", signpost_togreattree_entity)
-> DONE

== gameloop ==
// disable -> DONE to play story in ink
-> DONE

firequest: {firequest_steps}
treequest: {treequest_steps}

Select one:
+   Door: {towerdoor_entity} -> towerdoor
+   animal1: {animal1_entity} -> animal1
+   animal2: {animal2_entity} -> animal2
+   animal3: {animal3_entity} -> animal3
+   greattree: {greattree_entity} -> greattree
+   bucket: {bucket_entity} -> bucket
+   stream: {stream_entity} -> stream
+   forestfire: {forestfire_entity} -> forestfire
+   bookshelf: {bookshelf_entity} -> bookshelf
+   charred wood: {charredwood_entity} -> charredwood
+   bed: {bed_entity} -> bed
+   greattreerestored: {greattreerestored_entity} -> greattreerestored
-   -> gameloop





== animal1 ==
// spider
-> shared


== animal2 ==
// vole
{get_current_level() == TowerDayOne && shared.intro && step_completed(firequest_steps, tellAnimalsFireIsOut) && not ate_cheese: -> ate_cheese}
-> shared

= ate_cheese
Hmm?
*   [Ate all the cheese yet?]
-   I'm a vole, not a rat.
*   [My mistake]
-   Got any tubers?    
-> gameloop

== animal3 ==
// bear
{get_current_level() == TowerDayOne && shared.intro && step_completed(firequest_steps, tellAnimalsFireIsOut) && not bear_food: -> bear_food}
-> shared

= bear_food
Have any spare honey around here?
*   [No]
-   What about fish? A big juicy salmon would really hit the spot.
*   [Eat the {animal2.ate_cheese: vole | little rat}?]
-   Vole is my friend!
-> gameloop


== shared ==
{not intro: -> intro}
{not step_completed(firequest_steps, tellAnimalsFireIsOut): ->is_fire_out}
{not step_completed(treequest_steps, treeNeedsMagic): ->is_tree_ok}
{not step_completed(treequest_steps, regrowthRunePlaced) && not animals_know_about_rune: ->know_how_to_heal_it}
{not step_completed(treequest_steps, waitUntilTomorrow) && animals_know_about_rune && not animals_know_rune_placed: ->has_used_rune_yet}
{not step_completed(treequest_steps, waitUntilTomorrow) && animals_know_rune_placed: ->goodnight}
{get_current_level() == GreatTreeDayTwo: -> next_morning}
{Bit drafty in here, isn't it? | This place could use a bit of dusting. | Need anything?}

= intro
Morning, Witch. {not towerdoor: Late riser, aren't you?}
*   [Why are you here?] 
    Because the forest is on fire!
*   [Get out]
    I'm not leaving while the forest is on fire!
-   <>
*   {not step_completed(firequest_steps, forestIsOnFire)}[Fire?]
    Yes, fire. And <>

-   you're our only hope to get it out!
    ~   complete_quest_step(firequest_steps, forestIsOnFire)
-> gameloop


= is_fire_out
Did you put the fire out yet?
    *   [Why me?]
        You're the Witch of the Woods, aren't you?
        * * [Just a hedge witch]
            Yes, I know. Don't even have a wand. Very disappointing.
            Surely you have some way of getting the fire out, though?
    +   {not forestfire}[No]
        Please go and look, at least! It's going to burn the whole forest down.
    +   {forestfire && not step_completed(firequest_steps, fireIsOut)}[No]
        {~Please find a way to put the fire out | You're our only hope. | You're the Witch of the Woods. Surely you can put it out!}
    *   {step_completed(firequest_steps, fireIsOut)}[Yes]
        Yay! You are our hero, Witch! <>
        ~ complete_quest_step(firequest_steps, tellAnimalsFireIsOut)
        ->check_great_tree
-   -> gameloop



= check_great_tree
Did the fire get the Great Tree?
    *   {not quest_started(treequest_steps)}[The Great Tree?]
        The Great Tree in the clearing! It's guards the forest and allows all the other trees and plants to grow. If it's been hurt...
        ~ complete_quest_step(treequest_steps, treeAtRisk)
        -> is_tree_ok
    *   {quest_started(treequest_steps)}[I have bad news]->tree_is_burned



= is_tree_ok
{So, have you seen the Great Tree?|Have you checked on the Great Tree yet?}
    +   {not step_completed(treequest_steps, treeIsBurned)} [No]
        Please check! If it's been hurt in the fire, I don't know what we'll do.
    *   [Why should I?]
        If the Great Tree is hurt, the forest will never regrow!
    *   {step_completed(treequest_steps, treeIsBurned)}[I have bad news]-> tree_is_burned
-   -> gameloop


= tree_is_burned
Oh no. Is it burned?
    *   [Yes]
- You must save it!
    *   [How?]
    *   [Why me?]
        You're the Witch!<> 
- Surely you know some magic that could heal it?
    * [Maybe]
    ~ complete_quest_step(treequest_steps, treeNeedsMagic)
-   -> gameloop


= know_how_to_heal_it
Have you found a way to save the Great Tree?
    +   {not step_completed(treequest_steps, treeNeedsRegrowthRune)}[Not yet]
        Check your books! Surely there must be a way.
    *   (animals_know_about_rune){step_completed(treequest_steps, treeNeedsRegrowthRune)}[Yes]
        Show me. That's a Regrowth Rune? That might actually work. Well done, Witch!
-   -> gameloop


= has_used_rune_yet
Have you drawn the rune yet?
    +   {not step_completed(treequest_steps, regrowthRunePlaced)}[No]
    Please hurry! Surely the Great Tree doesn't have much time. -> gameloop
    *   (animals_know_rune_placed){step_completed(treequest_steps, regrowthRunePlaced)}[Yes]
    And, what? There was no change?
    * *     [No change]
            Well, growing takes time, so does regrowing I'd assume. Perhaps you need to check it after a night's rest. -> gameloop
    +   -> gameloop

= goodnight
{Get a good sleep, witch. | Too late to go back to the forest. I'll just be spending the night here. | We can check on the Great Tree in the morning. | Goodnight.} 
-> gameloop

= next_morning
{You did it! You saved the Great Tree! | You see how the whole clearing has regrown? Thank you, Witch! | It's nice to be home again! No offense, but that tower was a bit drafty. | I'm so glad the Tree is alive again! | We should throw a party for the whole forest!}
-> gameloop



== greattree ==
{not intro: -> intro}
Only a charred stump remains.
+   {step_active(treequest_steps, regrowthRunePlaced)}[Draw Regrowth Rune]-> draw_rune
+   -> gameloop


= intro
{quest_started(treequest_steps): This must be The Great Tree. You remember it now. The tree is burned to a husk of its former glory, leaving only the charred remains of a stump. | Even burned to a stump, you still recognize the former Great Tree of the forest. The animals will want to know what came of it.}
~   complete_quest_step(treequest_steps, treeIsBurned)
-> gameloop

= draw_rune
{
    - not inventory_count("charcoal"):
        You don't have anything to draw the rune with. Perhaps you should check the directions in your journal? -> gameloop
    - else:
        ~   emit_signal("rune_placed")
        You draw the Regrowth Rune on the Great Tree's burned stump. It glows briefly, then fades.
        ~   remove_item("charcoal", 1)
        *   [Wait]
            Nothing else happens. Does it take time to work? Maybe you should check again later.
            ~ complete_quest_step(treequest_steps, regrowthRunePlaced)
            -> gameloop
}


== greattreerestored ==
The Great Tree's burnt stump has been restored to its former glory, its long green branches extending to the sunlight.
~ complete_quest_step(treequest_steps, treeIsRegrown)
~ emit_signal("game_over_win_requested")
-> gameloop




== bucket ==
Your trusty wooden bucket.
*   (took_bucket)[Take bucket]
~   add_item("empty_bucket", 1)
~   disable_instance()
+   [Leave the bucket]
-   -> gameloop



== stream ==
A peaceful forest stream.<>
{
    - inventory_count("empty_bucket"):
        -> fill_bucket
    - quest_started(firequest_steps):
        <>The stream has plenty of fresh water. If only it could be put on the fire...
}
-> gameloop


= fill_bucket
*   [Fill bucket]
~   emit_signal("water_bucket_filled")
~   remove_item("empty_bucket", 1)
~   add_item("water_bucket", 1)
~   disable_entity("stream", stream_entity)
-   -> gameloop






== forestfire
{inventory_count("water_bucket"): -> put_out_fire}

+   [Put out fire]
    You don't have anything to use to put the fire out.
+   [Leave]
-   -> gameloop

= put_out_fire
+   [Throw water on fire]
~   emit_signal("fire_extinguished")
~   disable_instance()
{put_out_fire >= 5:<>-> all_fires_are_out}
-> gameloop

= all_fires_are_out
~   emit_signal("fire_crackling_stopped")
~   complete_quest_step(firequest_steps, fireIsOut)
~   enable_entity("charredwood", charredwood_entity)
~   enable_entity("greattree", greattree_entity)
-> gameloop






== bookshelf ==
{step_active(treequest_steps, treeNeedsRegrowthRune): -> search_for_spell}
A modest collection of tomes{   filled with runes, potions and minor spells fit for a hedge witch such as yourself|}.
-> gameloop

= search_for_spell
Perhaps you could find something to help the Great Tree on your shelves?
*   [Search]
    You find the Rune of Regrowth, which looks like exactly what you need.
    ~ complete_quest_step(treequest_steps, treeNeedsRegrowthRune)
    You copy down the shape of the rune and scribble down the directions in your journal.
    ~ add_item("rune_sketch", 1)
-> gameloop



== charredwood ==
The remains of a tree.
*   [Search]
    You salvage some charcoal.
    ~   add_item("charcoal", 1)
    ~   disable_instance()
-> gameloop



== bed ==
{step_active(treequest_steps, waitUntilTomorrow): -> go_to_sleep}
It is a bit early to sleep, isn't it?
-> gameloop

= go_to_sleep
*   [Sleep]
    You sleep.
    ~   change_level(TowerDayTwo)
    ~   complete_quest_step(treequest_steps, waitUntilTomorrow)
    -> gameloop





== towerdoor ==
#no_dialogue
~   emit_signal("door_opened")
{get_current_level() == TowerDayOne or get_current_level() == TowerDayTwo: <-tower_to_forest | <-forest_to_tower}<>
-   <> ->gameloop

= tower_to_forest
    {
        -   step_completed(treequest_steps, waitUntilTomorrow):
            ~   change_level(ForestDayTwo)
        -   else:
            ~ change_level(ForestDayOne)
    }
    -> DONE

= forest_to_tower
    {
        -   step_completed(treequest_steps, waitUntilTomorrow):
            ~   change_level(TowerDayTwo)
        -   else:
            ~ change_level(TowerDayOne)
    }
    -> DONE



== signpost_toforest ==
#no_dialogue
{
    -   step_completed(treequest_steps, waitUntilTomorrow):
        ~   change_level(ForestDayTwo)
    -   else:
        ~   change_level(ForestDayOne)
}
~ emit_signal("fire_crackling_stopped")
-> DONE




== signpost_togreattree ==
#no_dialogue
{
    -   step_completed(treequest_steps, waitUntilTomorrow):
        ~   change_level(GreatTreeDayTwo)
        ~   emit_signal("victory_music_requested")
    -   else:
        ~   change_level(GreatTreeDayOne)
}
{
    -   not step_completed(firequest_steps, fireIsOut):
        ~ emit_signal("fire_crackling_started")
}
~   complete_quest_step(firequest_steps, forestIsOnFire)
-> DONE



== journal ==
\{
    "quests": [
        \{
            "title": "The Great Tree",
            "description": "The forest creatures are worried about the fate of Great Tree.",
            <-quest_status(treequest_steps)
            "steps": [
                \{
                    "title":"Investigate tree",
                    <-quest_step_status(treequest_steps, treeIsBurned)
                \},
                \{
                    "title":"Tell the animals the tree's fate",
                    <-quest_step_status(treequest_steps, treeNeedsMagic)
                \},
                \{
                    "title":"Find a magical way to help the tree",
                    <-quest_step_status(treequest_steps, treeNeedsRegrowthRune)
                \},
                \{
                    "title":"Draw the Regrowth Rune on the Great Tree's stump",
                    <-quest_step_status(treequest_steps, regrowthRunePlaced)
                    "trackers": [
                        "Charcoal: {inventory_count("charcoal")}/1",
                        "Sketch of rune: {inventory_count("rune_sketch")}/1",
                    ]
                \},
                \{
                    "title":"Give the tree some time",
                    <-quest_step_status(treequest_steps, waitUntilTomorrow)
                \},
                \{
                    "title":"Check the tree again",
                    <-quest_step_status(treequest_steps, treeIsRegrown)
                \},
            ]
        \},
        \{
            "title": "Forest Fire",
            "description": "The forest is on fire.",
            <-quest_status(firequest_steps)
            "steps": [
                \{
                    "title":"Put the fire out",
                    <-quest_step_status(firequest_steps, fireIsOut)

                \}, 
                                \{
                    "title":"Tell the animals the fire is out",
                    <-quest_step_status(firequest_steps, tellAnimalsFireIsOut)

                \},
            ]
        \},
    ]
\}

-> DONE




                    

= quest_status(ref quest_steps)
"started":{quest_started(quest_steps)},
"completed":{quest_completed(quest_steps)},
-> DONE

= quest_step_status(ref quest_steps, step)
"started":{quest_steps ? (step-1)},
"completed":{quest_steps ? step},
-> DONE





// FUNCTIONS

== function disable_entity(entity_name, ref entity) ==
~   entity += disabled
~   entity -= enabled
~   entity_state_changed(entity_name, entity)

== function enable_entity(entity_name, ref entity) ==
~   entity -= disabled
~   entity += enabled
~   entity_state_changed(entity_name, entity)


== function complete_quest_step(ref quest_steps, completed_step) ==
{ quest_steps ? completed_step:
~    return
}
~ quest_steps += completed_step
~ temp next_step = completed_step + 1
~ update_quest_target(next_step)
~ journal_updated()






== function set_quest_target(target, quest) ==
~   _update_target_entity(target, "towerdoor", towerdoor_entity, quest)

== function _update_target_entity(target_name, entity_name, ref entity, quest) ==
~ temp previous_entity = entity
{   target_name == entity_name:
    ~   entity += quest
-   else:
    ~   entity -= quest
}
{   entity != previous_entity:
~    entity_state_changed(entity_name, entity)
}


== function entity_state_changed(entity_name, entity_state) ==
~ temp canInteract = entity_state ? enabled
~ temp isQuestTarget = is_quest_target(entity_state)
~ emit_entity_state_changed(entity_name, canInteract, isQuestTarget)



== function is_quest_target(entity_state) ==
{   LIST_ALL(Quests) ^ entity_state:
    ~   return true
-   else:
    ~   return false
}




== function remove_quest_target(ref entity_state, quest) ==
~   entity_state -= quest

== function add_quest_target(ref entity_state, quest) ==
~   entity_state += quest




== function step_active(quest_steps, quest_step) ==
~   return LIST_VALUE(active_step(quest_steps)) == LIST_VALUE(quest_step)

== function step_completed(quest_steps, quest_step) ==
~   return quest_steps ? quest_step

== function active_step(ref quest_steps) ==
~   return LIST_MAX(quest_steps) + 1

== function quest_started(ref quest_steps) ==
// coerce quest step list to bool
~   return not (not quest_steps)

== function quest_completed(ref quest_steps) ==
// check if last step is completed
~    return quest_steps ? LIST_MAX(LIST_ALL(quest_steps))

== function update_quest_target(activestep) ==
{ activestep:

// firequest
-   forestIsOnFire:
    ~   set_quest_target("forest_fire", firequest)
-   fireIsOut:
    ~   set_quest_target("none", firequest)
// LIST treequest_steps = treeIsBurned, treeNeedsMagic, treeNeedsRegrowthRune, runeNeedsIngredients, healingRunePlaced, healingRuneActivated, treeIsHealed
} 



// EXTERNAL FUNCTIONS
== function emit_signal(signalName) ==
~   return

== function journal_updated() ==
[Journal Updated]

== function inventory_count(item) ==
{ item:
    -   "empty_bucket": {
        - bucket.took_bucket && not stream.fill_bucket:
            ~   return 1
        - else:
            ~   return 0
        }
    -   "water_bucket": {
        - stream.fill_bucket:
            ~   return 1
        - else:
            ~   return 0
        }
    -   "charcoal": {
        - charredwood:
            ~ return 1 
        - else:
            ~ return 0
        }
}
~   return 0

== function add_item(item, quantity) ==
[{item} ({quantity}) added]

== function remove_item(item, quantity) ==
[{item} ({quantity}) removed]

== function disable_instance() ==
[Instance Disabled]

== function emit_entity_state_changed(entity_name, canInteract, isQuestTarget) ==
[Emit Signal: entity_state_changed({entity_name}, canInteract={canInteract}, isQuestTarget={isQuestTarget}]


== function change_level(level_name) ==
~   return

== function get_current_level() ==
~   return

 
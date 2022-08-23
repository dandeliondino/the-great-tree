extends Node

# GAME
signal new_game_requested
signal restart_game_requested
signal quit_requested
signal game_over_win_requested
signal game_over_lose_requested
signal main_scene_ready
signal game_manager_ready

# GAME STATE
signal game_state_changed(from_state, to_state)
signal game_state_requested(state)
signal game_state_exit_requested

# LEVELS
signal change_level_requested(new_level)
signal level_changing(level_name)
signal level_unloading(level_name)
signal level_unloaded(level_name)
signal level_loading(level_name)
signal level_loaded(level_name)
signal faded_to_black()
signal faded_to_game()

# MENUS
signal main_menu_requested
signal about_menu_requested
signal pause_menu_requested

# PANELS
signal inventory_panel_requested
signal journal_panel_requested

# HUD
signal show_interact_hint_requested(entity_def)
signal hide_interact_hint_requested
signal interact_button_pressed
signal notification_requested

# INTERACTABLES
signal current_interactable_change_requested(node)
signal current_interactable_changed(from_node, to_node)
signal disable_current_interactable
signal entity_state_changed(entity_name, canInteract, isQuestTarget)


# INVENTORY
signal add_inventory_item(item)
signal inventory_item_changed(index)
signal inventory_slot_focus_changed(index)
signal monitored_item_changed(item_id, quantity)

# QUESTS
signal journal_updated()

# DIALOGUE
signal ink_path_requested(path)
signal dialogue_started
signal dialogue_ended
signal dialogue_jump_to_end_requested
signal dialogue_typing_completed
signal dialogue_choice_pressed
signal speaker_changed(speaker)


# UI/AUDIO
signal UI_button_pressed
signal UI_button_focused
signal UI_panel_opened
signal UI_panel_closed
signal sfx_coins
signal sfx_inventory_item
signal rune_placed
signal water_bucket_filled
signal fire_crackling_started
signal fire_crackling_stopped
signal fire_extinguished
signal door_opened
signal victory_music_requested

# DEBUG
signal debug_audio_played(value)

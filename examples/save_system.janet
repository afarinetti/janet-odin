# Save/Load System - Game State Persistence
# ==========================================
# Odin handles file I/O and serialization.
# This script defines what data to save/load and how to transform it.
#
# Odin registers:
#   odin_save_game, odin_load_game, odin_delete_save
#   odin_get_save_slots, odin_get_player_state
#
# Odin calls:
#   (get-save-data) -> save-data-table
#   (load-save-data data) -> nil
#   (can-load? slot-id) -> boolean

(def save-version 1)

# --- Save Data Structure ---

(defn get-save-data []
  "Collect all game state for saving.
   Called by Odin when player saves the game.
   Returns: save-data table"
  (let [player-state (odin_get_player_state)]
    @{:version save-version
     :timestamp (os/time)
     :player @{:position (get-in player-state [:position])
              :health (get-in player-state [:health])
              :mana (get-in player-state [:mana])
              :inventory (get-in player-state [:inventory])
              :equipment (get-in player-state [:equipment])
              :stats (get-in player-state [:stats])
              :flags (get-in player-state [:flags])}}))

(defn load-save-data [data]
  "Restore game state from save data.
   Called by Odin after loading a save file.
   Returns: boolean (success?)"
  (let [version (get data :version)]
    # Check version compatibility
    (if (not= version save-version)
      (do
        (print "Warning: Save version mismatch")
        (print "Save version:" version "Current version:" save-version))
      nil)
    
    # Restore player state
    (let [player-data (get data :player)]
      (odin_set_player_position (get player-data :position))
      (odin_set_player_health (get player-data :health))
      (odin_set_player_mana (get player-data :mana))
      (odin_set_inventory (get player-data :inventory))
      (odin_set_equipment (get player-data :equipment))
      (odin_set_player_stats (get player-data :stats))
      (each [flag-key flag-value] (get player-data :flags @{})
        (odin_set_flag flag-key flag-value)))
    
    true))

(defn can-load? [slot-id]
  "Check if a save slot can be loaded.
   Called by Odin to determine if load button should be enabled.
   Returns: boolean"
  (let [save-data (odin_load_game slot-id)]
    (if save-data
      (let [version (get save-data :version)]
        (or (= version save-version)
            (and (> version 0) (<= version save-version))))
      false)))

(defn get-save-info [slot-id]
  "Get save slot metadata for UI display.
   Returns: @{:exists boolean :timestamp number :player-level number}"
  (let [save-data (odin_load_game slot-id)]
    (if save-data
      @{:exists true
       :timestamp (get save-data :timestamp)
       :player-level (get-in save-data [:player :stats :level] 1)
       :play-time (get-in save-data [:world :time] 0.0)}
      @{:exists false})))

# --- Save Slot Management ---

(defn get-all-saves []
  "Get info for all save slots.
   Called by Odin for save/load menu.
   Returns: array of save-info tables"
  (let [slots (odin_get_save_slots)]
    (map (fn [slot-id]
           (let [info (get-save-info slot-id)]
             (put info :slot-id slot-id)
             info))
         slots)))

(defn delete-save [slot-id]
  "Delete a save file.
   Called by Odin when player confirms deletion.
   Returns: boolean (success?)"
  (odin_delete_save slot-id))

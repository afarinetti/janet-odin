# Event System - Scripted Event Handlers
# =======================================
# Odin dispatches game events to this script. Each handler receives
# a table of event data and can call back into Odin to modify state.
#
# Odin registers:
#   odin_spawn_entity, odin_play_sound, odin_add_particle, odin_get_player
#
# Odin dispatches events by calling:
#   (handle-event event-name event-data)

(def event-handlers @{})

(defn register-handler [event-name handler]
  "Register an event handler. Called at script load time."
  (put event-handlers event-name handler)
  nil)

(defn handle-event [event-name data]
  "Main dispatch - called by Odin when an event occurs.
   Returns true if handled, false if no handler registered."
  (let [handler (get event-handlers event-name)]
    (if handler
      (do (handler data) true)
      false)))

# --- Player events ---

(defn on-player-damage [data]
  "Called when the player takes damage.
   data: @{:amount number :source entity-id :player entity-id}"
  (let [player-id (get data :player)
        amount (get data :amount)]
    (odin_apply_damage player-id amount)
    (odin_play_sound "player_hit" (odin_get_entity player-id))
    (when (<= (get (odin_get_entity player-id) :health 0) 0)
      (odin_spawn_entity :death-effect (get (odin_get_entity player-id) :position)))))

(defn on-item-collect [data]
  "Called when player picks up an item.
   data: @{:item item-id :player entity-id}"
  (let [player-id (get data :player)
        item-id (get data :item)]
    (odin_add_to_inventory player-id item-id 1)
    (odin_play_sound "item_pickup" (odin_get_entity player-id))
    (odin_add_particle "sparkle" (get (odin_get_entity player-id) :position))))

(defn on-dialogue-start [data]
  "Called when player interacts with an NPC.
   data: @{:npc entity-id :player entity-id}
   Returns: dialogue tree table for Odin to render"
  (let [npc-id (get data :npc)
        npc (odin_get_entity npc-id)
        dialogue-id (get npc :dialogue-id)]
    # Return structured data for Odin's UI layer
    @{:dialogue-id dialogue-id
     :npc-name (get npc :display-name)
     :lines (get npc :dialogue-lines [])}))

# Register handlers at load time
(register-handler :player-damage on-player-damage)
(register-handler :item-collect on-item-collect)
(register-handler :dialogue-start on-dialogue-start)

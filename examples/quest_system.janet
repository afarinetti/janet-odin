# Quest System - Data-Driven Quests
# =================================
# Odin loads quest definitions from this script at startup.
# Quest conditions and rewards are Janet functions that Odin calls.
#
# Odin registers:
#   odin_get_player_state, odin_give_xp, odin_give_item, odin_unlock_location
#
# Odin calls:
#   (check-quest-conditions quest-id) -> boolean
#   (complete-quest quest-id) -> rewards table

(def quests @{})

(defn define-quest [id quest-data]
  "Register a quest. Called at script load."
  (put quests id quest-data)
  nil)

# --- Quest Definitions ---

(define-quest :lost-sword
  @{:name "The Lost Sword"
   :description "Find the ancient sword in the northern cave"
   :objectives @[
     @{:type :collect :item :ancient-sword :count 1
      :check (fn [state] (>= (get-in state [:inventory :ancient-sword] 0) 1))}
     @{:type :talk-to :npc :blacksmith
      :check (fn [state] (get-in state [:flags :talked-to-blacksmith]))}
   ]
   :rewards (fn []
              (odin_give_xp 500)
              (odin_give_item :gold-coin 100)
              @{:xp 500 :items [@{:id :gold-coin :count 100}]})
   :prerequisites (fn [state]
                    (>= (get-in state [:stats :level] 0) 5))})

(define-quest :clear-cave
  @{:name "Clear the Cave"
   :description "Defeat 3 cave trolls"
   :objectives @[
     @{:type :kill :enemy :cave-troll :count 3
      :check (fn [state] (>= (get-in state [:kills :cave-troll] 0) 3))}
   ]
   :rewards (fn []
              (odin_give_xp 300)
              (odin_unlock_location :deep-cave)
              @{:xp 300 :unlocks [:deep-cave]})
   :prerequisites (fn [state]
                    (get-in state [:flags :quest-lost-sword-complete]))})

# --- Quest API called by Odin ---

(defn check-quest-conditions [quest-id]
  "Check if quest prerequisites are met.
   Called by Odin to determine if quest is available.
   Returns: boolean"
  (let [quest (get quests quest-id)]
    (when quest
      (let [prereqs (get quest :prerequisites)]
        (if prereqs (prereqs (odin_get_player_state)) true)))))

(defn check-objective [quest-id objective-index]
  "Check if a specific objective is complete.
   Called by Odin each frame or on state change.
   Returns: boolean"
  (let [quest (get quests quest-id)
        objectives (get quest :objectives @[])
        objective (get objectives objective-index)]
    (when objective
      (let [check-fn (get objective :check)]
        (if check-fn (check-fn (odin_get_player_state)) false)))))

(defn complete-quest [quest-id]
  "Complete a quest and grant rewards.
   Called by Odin when all objectives are met.
   Returns: rewards table"
  (let [quest (get quests quest-id)
        rewards-fn (get quest :rewards)]
    (when rewards-fn
      (rewards-fn))))

(defn get-quest-info [quest-id]
  "Get quest metadata for UI display.
   Returns: @{:name string :description string :objectives [...]} "
  (let [quest (get quests quest-id)]
    (when quest
      @{:name (get quest :name)
       :description (get quest :description)
       :objectives (map (fn [obj] @{:type (get obj :type) :count (get obj :count 1)})
                        (get quest :objectives @[]))})))

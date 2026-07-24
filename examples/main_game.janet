# Main Game Script - Entry Point
# ==============================
# This is the main script that Odin loads at game startup.
# It imports and initializes all subsystems, then provides
# the main update loop that Odin calls each frame.
#
# Odin loads this script first, which loads all other scripts.
# Odin then calls:
#   (game-init) -> nil
#   (game-update delta-time) -> nil
#   (game-shutdown) -> nil

# Import other game systems
# (In a real setup, these would be separate files loaded by Odin)
# For this example, we assume they're already loaded

# --- Game State ---

(var game-state
  @{:running false
   :player-id nil
   :entities @{}
   :time 0.0
   :flags @{}})

# --- Initialization ---

(defn game-init []
  "Called by Odin once at game startup.
   Initializes all game systems.
   Returns: nil"
  (print "Initializing game...")
  
  # Create player entity
  (let [player-id (odin_spawn_entity 'player @{:position @{:x 0.0 :y 0.0}
                                               :health 100
                                               :mana 50
                                               :inventory @{}})]
    (put game-state :player-id player-id)
    (put game-state :running true)
    (print "Player created with ID:" player-id))
  
  # Spawn some enemies
  (for i 0 3
    (let [enemy-id (odin_spawn_entity 'enemy
                     @{:position @{:x (+ 10.0 (* i 5.0)) :y 10.0}
                      :health 50
                      :level 1
                      :type 'enemy})]
      (put-in game-state [:entities enemy-id] @{:type 'enemy :level 1})))
  
  (print "Game initialized successfully"))

# --- Main Update Loop ---

(defn game-update [dt]
  "Called by Odin each frame.
   dt: delta time in seconds
   Returns: nil"
  (when (get game-state :running)
    # Update game time
    (put game-state :time (+ (get game-state :time 0.0) dt))
    
    # Update player
    (let [player-id (get game-state :player-id)]
      (when player-id
        (update-player player-id dt)))
    
    # Update all enemies
    (each [entity-id entity-data] (get game-state :entities)
      (when (and entity-data (= (:type entity-data) 'enemy))
        (update-enemy entity-id dt)))
    
    # Check for collisions (Odin provides collision pairs)
    # This would be called by Odin's physics system
    ))

(defn game-shutdown []
  "Called by Odin when game is shutting down.
   Returns: nil"
  (print "Shutting down game...")
  (put game-state :running false)
  (print "Game shutdown complete"))

# --- Event Handlers ---

(defn on-player-input [input-data]
  "Called by Odin when player provides input.
   input-data: @{:move-x number :move-y number :action keyword}"
  (let [player-id (get game-state :player-id)]
    (when player-id
      (case (get input-data :action)
        :attack
          (let [target-id (odin_get_nearest_enemy player-id 5.0)]
            (when target-id
              (let [damage-table (calculate-damage player-id target-id :normal)]
                (odin_apply_damage target-id (get damage-table :damage))
                (on-hit player-id target-id damage-table))))
        
        :use-item
          (let [item-id (get input-data :item-id)]
            (when item-id
              (on-item-use item-id player-id)))
        
        # Default - just movement
        nil))))

(defn on-entity-collision [entity-a-id entity-b-id]
  "Called by Odin when two entities collide.
   Returns: boolean (handled?)"
  (on-collision entity-a-id entity-b-id))

(defn on-quest-complete [quest-id]
  "Called by Odin when all quest objectives are met.
   Grants rewards.
   Returns: nil"
  (let [rewards (complete-quest quest-id)]
    (print "Quest completed:" quest-id)
    (print "Rewards:" rewards)))

# --- Utility Functions ---

(defn get-game-state []
  "Get current game state.
   Called by Odin for debugging/saving.
   Returns: game-state table"
  game-state)

(defn spawn-test-enemy []
  "Spawn a test enemy.
   Called by Odin debug commands.
   Returns: entity-id"
  (let [player-id (get game-state :player-id)
        player (odin_get_entity player-id)
        pos (get player :position)]
    (odin_spawn_entity 'enemy
      @{:position @{:x (+ (get pos :x) 5.0) :y (get pos :y)}
       :health 50
       :level 1
       :type 'enemy})))

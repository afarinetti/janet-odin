# AI Behavior Tree - Scripted Decision Making
# ============================================
# Odin loads behavior tree definitions from this script.
# The tree is evaluated each frame by Odin, which calls
# behavior functions and checks conditions.
#
# Odin registers:
#   odin_get_entity, odin_get_player_id, odin_apply_velocity
#   odin_play_sound, odin_spawn_entity, odin_set_animation
#
# Odin calls:
#   (evaluate-behavior-tree entity-id) -> action-result

# Behavior tree node constructors
(defn make-sequence [& children]
  "Sequence: run children in order, fail if any fails"
  @{:type :sequence :children children})

(defn make-selector [& children]
  "Selector: run children in order, succeed if any succeeds"
  @{:type :selector :children children})

(defn make-condition [check-fn]
  "Condition leaf: returns true/false"
  @{:type :condition :fn check-fn})

(defn make-action [action-fn]
  "Action leaf: performs an action, returns true on success"
  @{:type :action :fn action-fn})

# --- Behavior Tree Definitions ---

(def enemy-behavior-tree
  "Enemy AI: attack if close, chase if visible, otherwise patrol"
  (make-selector
    # Priority 1: Attack if player is in range
    (make-sequence
      (make-condition (fn [entity-id]
                        (let [enemy (odin_get_entity entity-id)
                              player-id (odin_get_player_id)
                              player (odin_get_entity player-id)
                              dist (math/sqrt (+ 
                                (* (- (get-in player [:position :x]) (get-in enemy [:position :x])) 2)
                                (* (- (get-in player [:position :y]) (get-in enemy [:position :y])) 2)))]
                          (< dist 2.0))))
      (make-action (fn [entity-id]
                     (odin_set_animation entity-id :attack)
                     (odin_play_sound "enemy_attack" (odin_get_entity entity-id))
                     (let [player-id (odin_get_player_id)]
                       (odin_apply_damage player-id 15))
                     true)))
    
    # Priority 2: Chase if player is visible
    (make-sequence
      (make-condition (fn [entity-id]
                        (let [enemy (odin_get_entity entity-id)
                              player-id (odin_get_player_id)
                              player (odin_get_entity player-id)]
                          # Simple line-of-sight check
                          (and (get enemy :can-see-player)
                               (> (get-in player [:health] 0) 0)))))
      (make-action (fn [entity-id]
                     (let [enemy (odin_get_entity entity-id)
                           player-id (odin_get_player_id)
                           player (odin_get_entity player-id)
                           epos (get enemy :position)
                           ppos (get player :position)
                           dx (- (get ppos :x) (get epos :x))
                           dy (- (get ppos :y) (get epos :y))
                           dist (math/sqrt (+ (* dx dx) (* dy dy)))
                           speed 80.0]
                       (when (> dist 0.001)
                         (odin_apply_velocity entity-id
                           (* speed (/ dx dist))
                           (* speed (/ dy dist))
                           0.016))
                       (odin_set_animation entity-id :run)
                       true))))
    
    # Priority 3: Patrol
    (make-action (fn [entity-id]
                   (odin_set_animation entity-id :walk)
                   # Simple patrol logic - move in current direction
                   (let [enemy (odin_get_entity entity-id)
                         dir (get enemy :patrol-direction @{:x 1.0 :y 0.0})]
                     (odin_apply_velocity entity-id
                       (* 30.0 (get dir :x))
                       (* 30.0 (get dir :y))
                       0.016))
                   true))))

# --- Behavior Tree Evaluator ---

(defn evaluate-node [node entity-id]
  "Evaluate a single behavior tree node.
   Returns true if node succeeded, false if failed."
  (case (:type node)
    :sequence
      (let [results (map (fn [child] (evaluate-node child entity-id)) (:children node))]
        (every? results))
    
    :selector
      (let [results (map (fn [child] (evaluate-node child entity-id)) (:children node))]
        (some identity results))
    
    :condition
      (let [check-fn (get node :fn)]
        (if check-fn (check-fn entity-id) false))
    
    :action
      (let [action-fn (get node :fn)]
        (if action-fn (action-fn entity-id) false))
    
    # Default
    false))

(defn evaluate-behavior-tree [entity-id]
  "Main entry point - called by Odin each frame.
   Returns: @{:action keyword :success boolean}"
  (let [success (evaluate-node enemy-behavior-tree entity-id)]
    @{:action :behavior-evaluated :success success}))

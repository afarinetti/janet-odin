# ECS Behavior Script
# ===================
# This script is loaded and executed by Odin at game startup.
# Odin registers C functions (odin_get_input, odin_apply_velocity, etc.)
# that this script calls. Odin then calls update_entity each frame.
#
# Odin side:
#   janet_engine.janet_register(eng, "odin_get_input", odin_get_input)
#   janet_engine.janet_register(eng, "odin_apply_velocity", odin_apply_velocity)
#   janet_engine.janet_register(eng, "odin_check_collision", odin_check_collision)
#
# Each frame, Odin calls:
#   (update-entity entity-id delta-time)
# where entity-id is an integer and delta-time is a number.

(defn update-player [entity-id dt]
  "Called by Odin each frame for player entities.
   entity-id: integer ID of the entity
   dt: delta time in seconds
   Returns: nil (Odin reads entity state back via odin_get_entity)"
  (let [input (odin_get_input)
        speed 200.0]
    (odin_apply_velocity entity-id
      (* speed (get input :move-x 0.0))
      (* speed (get input :move-y 0.0))
      dt)))

(defn update-enemy [entity-id dt]
  "Simple chase AI. Calls odin_get_entity to read positions,
   odin_apply_velocity to move."
  (let [enemy (odin_get_entity entity-id)
        player-id (odin_get_player_id)
        player (odin_get_entity player-id)
        epos (get enemy :position)
        ppos (get player :position)
        dx (- (get ppos :x) (get epos :x))
        dy (- (get ppos :y) (get epos :y))
        dist (math/sqrt (+ (* dx dx) (* dy dy)))
        speed 100.0]
    (when (> dist 0.001)
      (odin_apply_velocity entity-id
        (* speed (/ dx dist))
        (* speed (/ dy dist))
        dt))))

(defn on-collision [entity-a-id entity-b-id]
  "Called by Odin when two entities collide.
   Returns true to confirm the collision was handled."
  (let [a-type (get (odin_get_entity entity-a-id) :type)
        b-type (get (odin_get_entity entity-b-id) :type)]
    (when (and (= a-type :player) (= b-type :enemy))
      (odin_apply_damage entity-a-id 10))
    true))

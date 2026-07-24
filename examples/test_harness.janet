# Test Harness - Mock Odin Functions
# ===================================
# This file provides mock implementations of Odin-registered functions
# so we can test Janet examples standalone.

# Mock entity storage (use var for mutable state)
(var _entities @{})
(var _next-entity-id 1)
(var _player-id nil)
(var _flags @{})
(var _player-state @{:position {:x 0.0 :y 0.0}
                    :health 100
                    :mana 50
                    :inventory {}
                    :equipment {}
                    :stats @{:level 1 :attack 10 :defense 5 :armor 2}
                    :flags @{}})

# Mock Odin functions
(defn odin_spawn_entity [type data]
  (let [id _next-entity-id]
    (put _entities id (merge @{:id id :type type} data))
    (set _next-entity-id (+ id 1))
    (when (= type :player)
      (set _player-id id))
    id))

(defn odin_get_entity [id]
  (get _entities id))

(defn odin_get_player_id []
  _player-id)

(defn odin_get_player_state []
  _player-state)

(defn odin_set_player_position [pos]
  (put _player-state :position pos))

(defn odin_set_player_health [health]
  (put _player-state :health health))

(defn odin_set_player_mana [mana]
  (put _player-state :mana mana))

(defn odin_set_inventory [inventory]
  (put _player-state :inventory inventory))

(defn odin_set_equipment [equipment]
  (put _player-state :equipment equipment))

(defn odin_set_player_stats [stats]
  (put _player-state :stats stats))

(defn odin_set_flag [key value]
  (put _flags key value)
  (put-in _player-state [:flags key] value))

(defn odin_apply_velocity [entity-id vx vy dt]
  (let [entity (get _entities entity-id)]
    (when entity
      (let [pos (get entity :position @{:x 0.0 :y 0.0})]
        (put entity :position
             @{:x (+ (get pos :x) (* vx dt))
              :y (+ (get pos :y) (* vy dt))})))))

(defn odin_apply_damage [entity-id amount]
  (let [entity (get _entities entity-id)]
    (when entity
      (let [health (get entity :health 100)]
        (put entity :health (max 0 (- health amount)))))))

(defn odin_apply_heal [entity-id amount]
  (let [entity (get _entities entity-id)]
    (when entity
      (let [health (get entity :health 0)]
        (put entity :health (+ health amount))))))

(defn odin_apply_effect [entity-id effect-type duration damage]
  (print "Applied effect:" effect-type "duration:" duration "damage:" damage))

(defn odin_get_input []
  @{:move-x 1.0 :move-y 0.0 :action nil})

(defn odin_get_nearest_enemy [entity-id radius]
  # Return first enemy found
  (each [id entity] _entities
    (when (and (= (get entity :type) :enemy)
               (< (math/sqrt (+ 
                 (* (- (get-in entity [:position :x]) (get-in (get _entities entity-id) [:position :x])) 2)
                 (* (- (get-in entity [:position :y]) (get-in (get _entities entity-id) [:position :y])) 2)))
                  radius))
      (return id)))
  nil)

(defn odin_set_animation [entity-id anim]
  (print "Set animation:" anim "for entity:" entity-id))

(defn odin_play_sound [sound entity]
  (print "Play sound:" sound))

(defn odin_add_particle [particle pos]
  (print "Add particle:" particle "at:" pos))

(defn odin_add_to_inventory [entity-id item-id count]
  (let [entity (get _entities entity-id)]
    (when entity
      (let [inventory (get entity :inventory {})]
        (put-in inventory [item-id :count] (+ (get-in inventory [item-id :count] 0) count))
        (put entity :inventory inventory)))))

(defn odin_restore_entity [entity-id data]
  (put _entities entity-id data))

(defn odin_save_game [slot-id data]
  (print "Save game to slot:" slot-id))

(defn odin_load_game [slot-id]
  nil)

(defn odin_delete_save [slot-id]
  (print "Delete save:" slot-id))

(defn odin_get_save_slots []
  [1 2 3])

(defn odin_unlock_location [location]
  (print "Unlock location:" location))

(defn odin_give_xp [amount]
  (print "Give XP:" amount))

(defn odin_give_item [item-id count]
  (print "Give item:" item-id "count:" count))

# Combat System - Damage Calculation and Effects
# ===============================================
# Odin handles physics, hit detection, and health tracking.
# This script defines combat rules, damage formulas, and effects.
#
# Odin registers:
#   odin_get_entity, odin_apply_damage, odin_apply_heal
#   odin_spawn_entity, odin_play_sound, odin_add_particle
#   odin_get_player_state
#
# Odin calls:
#   (calculate-damage attacker-id defender-id attack-type) -> damage-table
#   (on-hit attacker-id defender-id damage-table) -> nil
#   (on-death entity-id) -> nil

(def combat-constants
  @{:base-damage 10
   :crit-multiplier 2.0
   :crit-chance 0.15
   :armor-reduction 0.5})

# --- Damage Calculation ---

(defn calculate-damage [attacker-id defender-id attack-type]
  "Calculate damage for an attack.
   Called by Odin when a hit is detected.
   Returns: @{:damage number :crit? boolean :effects [...]}"
  (let [attacker (odin_get_entity attacker-id)
        defender (odin_get_entity defender-id)
        constants combat-constants
        base-dmg (get constants :base-damage)
        
        # Get attacker stats
        attack-power (get-in attacker [:stats :attack] base-dmg)
        weapon-bonus (get-in attacker [:equipment :weapon :stats :damage] 0)
        
        # Get defender stats
        armor (get-in defender [:stats :armor] 0)
        defense (get-in defender [:stats :defense] 0)
        
        # Calculate base damage
        raw-damage (+ attack-power weapon-bonus)
        
        # Apply armor reduction
        armor-reduction (* armor (get constants :armor-reduction))
        reduced-damage (max 1 (- raw-damage armor-reduction defense))
        
        # Check for critical hit
        is-crit (< (math/random) (get constants :crit-multiplier))
        final-damage (if is-crit
                       (* reduced-damage (get constants :crit-multiplier))
                       reduced-damage)
        
        # Determine effects based on attack type
        effects (case attack-type
                  :normal []
                  :fire [@{:type :burn :duration 3.0 :damage 5.0}]
                  :ice [@{:type :freeze :duration 1.5}]
                  :poison [@{:type :poison :duration 5.0 :damage 3.0}]
                  [])]
    @{:damage final-damage
     :crit? is-crit
     :effects effects
     :attack-type attack-type}))

(defn on-hit [attacker-id defender-id damage-table]
  "Handle a successful hit.
   Called by Odin after damage is applied.
   Returns: nil"
  (let [damage (get damage-table :damage)
        is-crit (get damage-table :crit?)
        effects (get damage-table :effects)
        defender (odin_get_entity defender-id)]
    
    # Play hit sound
    (odin_play_sound "hit" defender)
    
    (let [pos (get defender :position)
          damage-text @{:x (get pos :x) :y (get pos :y) :text (string (math/trunc damage))}]
      (odin_spawn_entity 'damage-number damage-text))
    # Critical hit effects
    (when is-crit
      (odin_play_sound "crit_hit" defender)
      (odin_add_particle "crit-sparkle" (get defender :position)))
    
    # Apply status effects
    (each effect effects
      (odin_apply_effect defender-id (get effect :type) (get effect :duration) (get effect :damage)))))

(defn on-death [entity-id]
  "Handle entity death.
   Called by Odin when health reaches 0.
   Returns: @{:xp number :loot [...]} "
  (let [entity (odin_get_entity entity-id)
        entity-type (get entity :type)
        level (get entity :level 1)]
    
    # Play death animation and sound
    (odin_set_animation entity-id :death)
    (odin_play_sound "death" entity)
    (odin_add_particle "death-effect" (get entity :position))
    
    # Calculate rewards
    (case entity-type
      :enemy
        @{:xp (* level 10)
         :loot [@{:item :gold-coin :count (* level 5)}]}
      
      :boss
        @{:xp (* level 100)
         :loot [@{:item :rare-item :count 1}]}
      
      # Default
      @{:xp 0 :loot []})))

# --- Combat Skills ---

(defn can-use-skill? [entity-id skill-id]
  "Check if entity can use a skill.
   Returns: boolean"
  (let [entity (odin_get_entity entity-id)
        mana (get-in entity [:mana] 0)
        skill-cost (get-in entity [:skills skill-id :mana-cost] 0)
        cooldown (get-in entity [:skills skill-id :cooldown] 0)
        current-time (get (odin_get_player_state) :time 0)]
    (and (>= mana skill-cost)
         (<= cooldown current-time))))

(defn use-skill [entity-id skill-id target-id]
  "Use a combat skill.
   Returns: @{:success boolean :damage number}"
  (let [entity (odin_get_entity entity-id)
        skill (get-in entity [:skills skill-id])]
    (when (can-use-skill? entity-id skill-id)
      # Deduct mana
      (let [new-mana (- (get-in entity [:mana] 0) (get skill :mana-cost))]
        (put-in entity [:mana] new-mana))
      
      # Apply skill effect
      (let [damage (get skill :damage 0)
            effect-type (get skill :effect-type)]
        (odin_apply_damage target-id damage)
        (odin_play_sound (get skill :sound) (odin_get_entity target-id))
        @{:success true :damage damage}))))

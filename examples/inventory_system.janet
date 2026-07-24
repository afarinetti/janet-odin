# Inventory System - Item Management
# ===================================
# Odin manages the actual inventory data structure and rendering.
# This script defines item behaviors and inventory rules.
#
# Odin registers:
#   odin_get_inventory, odin_set_inventory, odin_get_entity
#   odin_play_sound, odin_spawn_entity, odin_apply_effect
#
# Odin calls:
#   (can-pickup? item-id entity-id) -> boolean
#   (on-item-use item-id entity-id) -> success?
#   (on-item-discard item-id entity-id) -> success?

(def items @{})

(defn define-item [id item-data]
  "Register an item definition. Called at script load."
  (put items id item-data)
  nil)

# --- Item Definitions ---

(define-item :health-potion
  @{:name "Health Potion"
   :type :consumable
   :stackable? true
   :max-stack 99
   :on-use (fn [entity-id]
             (let [entity (odin_get_entity entity-id)
                   current-health (get-in entity [:health] 100)]
               (when (< current-health 100)
                 (odin_apply_effect entity-id :heal 25)
                 (odin_play_sound "potion_drink" entity)
                 true)))
   :description "Restores 25 health"})

(define-item :sword
  @{:name "Iron Sword"
   :type :equipment
   :slot :weapon
   :stackable? false
   :on-equip (fn [entity-id]
               (odin_set_animation entity-id :equip-weapon)
               (odin_play_sound "sword_equip" (odin_get_entity entity-id))
               true)
   :on-unequip (fn [entity-id]
                 (odin_set_animation entity-id :unequip-weapon)
                 true)
   :stats @{:damage 15 :speed 1.0}
   :description "A sturdy iron sword"})

(define-item :gold-coin
  @{:name "Gold Coin"
   :type :currency
   :stackable? true
   :max-stack 9999
   :description "Standard currency"})

(define-item :key
  @{:name "Rusty Key"
   :type :quest-item
   :stackable? false
   :on-use (fn [entity-id]
             # Keys are used on specific objects, not directly
             false)
   :description "Opens a locked door somewhere"})

# --- Inventory Rules ---

(defn can-pickup? [item-id entity-id]
  "Check if an entity can pick up an item.
   Called by Odin before adding item to inventory.
   Returns: boolean"
  (let [item (get items item-id)
        entity (odin_get_entity entity-id)
        inventory (get entity :inventory {})]
    (case (:type item)
      :consumable
        (let [current-count (get-in inventory [item-id :count] 0)
              max-stack (get item :max-stack 99)]
          (< current-count max-stack))
      
      :equipment
        (let [slot (get item :slot)]
          (not (get-in inventory [slot])))
      
      :currency
        (let [current-count (get-in inventory [item-id :count] 0)
              max-stack (get item :max-stack 9999)]
          (< current-count max-stack))
      
      :quest-item
        (not (get-in inventory [item-id]))
      
      # Default
      true)))

(defn on-item-use [item-id entity-id]
  "Handle item use.
   Called by Odin when player uses an item.
   Returns: boolean (success?)"
  (let [item (get items item-id)
        item-type (get item :type)]
    (case item-type
      :consumable
        (let [use-fn (get item :on-use)]
          (if use-fn (use-fn entity-id) false))
      
      :equipment
        (let [entity (odin_get_entity entity-id)
              inventory (get entity :inventory {})
              slot (get item :slot)
              currently-equipped (get-in inventory [slot])]
          # Unequip current item if any
          (when currently-equipped
            (let [old-item (get items currently-equipped)
                  unequip-fn (get old-item :on-unequip)]
              (when unequip-fn (unequip-fn entity-id))))
          # Equip new item
          (let [equip-fn (get item :on-equip)]
            (if equip-fn (equip-fn entity-id) false)))
      
      # Other types can't be used directly
      false)))

(defn on-item-discard [item-id entity-id]
  "Handle item discard/drop.
   Called by Odin when player drops an item.
   Returns: boolean (success?)"
  (let [item (get items item-id)]
    # Quest items can't be discarded
    (if (= (:type item) :quest-item)
      false
      true)))

(defn get-item-info [item-id]
  "Get item metadata for UI display.
   Returns: @{:name string :description string :type keyword ...}"
  (get items item-id))

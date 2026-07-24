# Dialogue System - Branching Conversations
# =========================================
# Odin loads dialogue definitions and manages the UI rendering.
# This script defines dialogue trees and handles player choices.
#
# Odin registers:
#   odin_get_player_state, odin_set_flag, odin_get_entity
#
# Odin calls:
#   (get-dialogue dialogue-id) -> dialogue-tree
#   (process-choice dialogue-id choice-index) -> next-state

(def dialogues @{})

(defn define-dialogue [id dialogue-data]
  "Register a dialogue tree. Called at script load."
  (put dialogues id dialogue-data)
  nil)

# --- Dialogue Definitions ---

(define-dialogue :blacksmith-intro
  @{:npc :blacksmith
   :lines [
     @{:speaker :blacksmith
      :text "Welcome to my forge! What can I do for you?"
      :choices [
        @{:text "I need a weapon forged"
         :next :blacksmith-forge
         :condition (fn [state] (>= (get-in state [:inventory :gold] 0) 50))}
        @{:text "Tell me about the ancient sword"
         :next :blacksmith-lore}
        @{:text "Nothing, thanks"
         :next :end}
      ]}
   ]})

(define-dialogue :blacksmith-forge
  @{:npc :blacksmith
   :lines [
     @{:speaker :blacksmith
      :text "I can forge you a fine blade. It'll cost 50 gold."
      :choices [
        @{:text "Forge it"
         :action (fn [state]
                   (let [new-gold (- (get-in state [:inventory :gold] 0) 50)]
                     (put-in state [:inventory :gold] new-gold)
                     (put-in state [:inventory :sword] (+ (get-in state [:inventory :sword] 0) 1))
                     (odin_set_flag :has-sword true)
                     state))
         :next :end}
        @{:text "Too expensive"
         :next :blacksmith-intro}
      ]}
   ]})

(define-dialogue :blacksmith-lore
  @{:npc :blacksmith
   :lines [
     @{:speaker :blacksmith
      :text "The ancient sword? Legend says it's hidden in the cave to the north. Many have sought it, few returned."
      :choices [
        @{:text "Where exactly is the cave?"
         :action (fn [state]
                   (odin_set_flag :knows-cave-location true)
                   state)
         :next :end}
        @{:text "Thanks for the information"
         :next :end}
      ]}
   ]})

# --- Dialogue API called by Odin ---

(defn get-dialogue [id]
  "Get a dialogue definition.
   Called by Odin when player initiates conversation.
   Returns: dialogue tree table"
  (get dialogues id))

(defn get-current-line [dialogue state]
  "Get the current dialogue line with filtered choices.
   Called by Odin to render dialogue UI.
   Returns: @{:speaker keyword :text string :choices [...]}"
  (let [lines (get dialogue :lines [])
        current-line (first lines)]
    (when current-line
      @{:speaker (:speaker current-line)
       :text (:text current-line)
       :choices (filter
                  (fn [choice]
                    (let [cond (get choice :condition)]
                      (if cond (cond state) true)))
                  (:choices current-line))})))

(defn process-choice [dialogue-id state choice-index]
  "Process a dialogue choice.
   Called by Odin when player selects a choice.
   Returns: @{:dialogue dialogue-or-nil :state new-state}"
  (let [dialogue (get dialogues dialogue-id)
        lines (get dialogue :lines [])
        current-line (first lines)
        choices (:choices current-line)
        choice (get choices choice-index)]
    (when choice
      # Execute action if present
      (let [action (get choice :action)
            new-state (if action (action state) state)
            next-id (get choice :next)]
        (if (= next-id :end)
          @{:dialogue nil :state new-state}
          @{:dialogue (get-dialogue next-id) :state new-state})))))

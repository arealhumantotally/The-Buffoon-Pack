--- STEAMODDED HEADER
--- MOD_NAME: The Buffoon Pack
--- MOD_ID: Me_TheBuffoonPack
--- MOD_AUTHOR: [Me]
--- MOD_DESCRIPTION: Adds 5 new jokers, a whole pack!
----------------------------------------------
------------MOD CODE -------------------------

function SMODS.INIT.Me_TheBuffoonPack()
-- GLADIATOR JOKER CODE
    local thismod = SMODS.findModByID("Me_TheBuffoonPack")
    sendInfoMessage(thismod.path, "TheBuffoonPack")
    
    SMODS.Sprite:new("j_Gladiator", thismod.path, "j_Gladiator.png",71,95, "asset_atli"):register();

    local GladiatorJoker = SMODS.Joker:new('Gladiator Joker', 'Gladiator', {}, {x=0,y=0}, {
    name= 'Gladiator Joker',
    text = { 'If the {C:attention}first hand{} of round', 'has exactly {C:attention}3{} cards,' ,'destroy 2 of them at random.', '{C:inactive}(If on first hand.', '{C:inactive}discard is used, or a hand is played that does not trigger this', '{C:inactive}this is destroyed)'}
    }, 3, 7, true, true, false, false)
    
    GladiatorJoker:register()
    SMODS.Jokers.j_Gladiator.set_ability = function(self, initial, delay)
        self.ability.safe = true
    end
    SMODS.Jokers.j_Gladiator.calculate = function(self, context)
        if context.first_hand_drawn then
            local eval = function() return G.GAME.current_round.hands_played == 0 and G.GAME.current_round.discards_used == 0 end
            card_eval_status_text(self, 'extra', nil, nil, nil, {message = "PRESENT THE CHALLENGERS!"})
            juice_card_until(self, eval, true)
            self.ability.safe = false
            
        end
        if context.after and #context.full_hand == 3 and G.GAME.current_round.hands_played == 0 and G.GAME.current_round.discards_used == 0 then
            self.ability.safe = true
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 1,
                func = function()  
                    local loser1 = pseudorandom_element(context.full_hand)
                    local loser2 = pseudorandom_element(context.full_hand)
                    sendInfoMessage("Played hand with gladiator", "TheBuffoonPack")
                    sendInfoMessage(#context.full_hand, "TheBuffoonPack")
                    if #context.full_hand < 3 then return true end
                    sendInfoMessage("Hand is proper with gladiator", "TheBuffoonPack")
                    if loser1 == loser2 then
                        while loser1 == loser2 do
                            loser2 = pseudorandom_element(context.full_hand)
                        end
                        
                    end
                    sendInfoMessage("Got past loop", "TheBuffoonPack")
                    if loser1.removed == nil and loser1 ~= nil then loser1:start_dissolve(nil,nil,3) end
                    if loser2.removed == nil and loser2 ~= nil then loser2:start_dissolve(nil,nil,3) end
                    card_eval_status_text(self, 'extra', nil, nil, nil, {message = "DIE!"})
                    return true
                end
            }))
            
        elseif context.after and not self.ability.safe then
            self:start_dissolve(nil,nil,3)
        elseif context.discard and not self.ability.safe then
            self:start_dissolve(nil,nil,3)
        end
    end
    -- END GLADIATOR JOKER CODE
    -- BEGIN TUNGSTEN JOKER
    SMODS.Sprite:new("j_Tungsten", thismod.path, "j_Tungsten.png",71,95, "asset_atli"):register();
    local TungstenJoker = SMODS.Joker:new('Tungsten Joker', 'Tungsten', {h_size = -1}, {x=0,y=0}, {
        name='Tungsten Joker',
        text= {'{C:attention}#1#{} Hand size,', 'breaks in {C:attention}three{} rounds to create {C:attention}The Soul{}', '{C:inactive}({C:attention}#2#{}{C:inactive}/3 rounds remain){}', '{C:inactive}(Must have room){}'}
    }, 3, 10, true, true, false, false)
    
    TungstenJoker:register()
    SMODS.Jokers.j_Tungsten.set_ability = function(self,initial,delay_sprites)
        self.ability.roundsuntilsoul = 3
        self.ability.jobsdone = false
    end
    SMODS.Jokers.j_Tungsten.calculate = function(self,context) 
        if context.first_hand_drawn then
            self.ability.jobsdone = false
        end
        if context.end_of_round and not context.repetition and not self.ability.jobsdone then
            if self.ability.roundsuntilsoul ~= 0 then
                self.ability.roundsuntilsoul = self.ability.roundsuntilsoul - 1
                self.ability.jobsdone = true
                if self.ability.roundsuntilsoul == 0 then
                    if G.consumeables.cards ~= nil then
                        if #G.consumeables.cards < G.consumeables.config.card_limit then
                            local OurSoul = create_card("Spectral", G.consumables, nil, nil, nil, nil, "c_soul")
                            OurSoul:add_to_deck()
                            G.consumeables:emplace(OurSoul)
                        end
                        self:start_dissolve(nil,nil,3)
                    else
                        local OurSoul = create_card("Spectral", G.consumables, nil, nil, nil, nil, "c_soul")
                        OurSoul:add_to_deck()
                        G.consumeables:emplace(OurSoul)
                        self:start_dissolve(nil,nil,3)
                    end
                end
                sendInfoMessage("REDUCED SOUL COUNT", "TheBuffoonPack")
                return {
                    message = "Strength Up!",
                    colour = G.C.RED
                }
            end
            return {
                message = "MAXIMUM POWER!",
                colour = G.C.RED
            }
            
        end
    end
    SMODS.Jokers.j_Tungsten.loc_def = function(card)
        return {card.ability.h_size, card.ability.roundsuntilsoul}
    end
    -- END TUNGSTEN JOKER
    -- START MANSION JOKER
    SMODS.Sprite:new("j_Mansion", thismod.path, "j_Mansion.png",71,95, "asset_atli"):register();
    local Mansion = SMODS.Joker:new('Mansion', 'Mansion', {}, {x=0, y=0}, {
        name= 'Rich Joker',
        text= {'If played poker hand contains a {C:attention}Full House{}, ', 'give a card a random {C:attention}Edition{} and, ', ' lose ${C:money}3{}'}
    }, 2, 5, true, true, true, true)
    Mansion:register()
    SMODS.Jokers.j_Mansion.calculate = function(self,context)
        if context.after and next(context.poker_hands['Full House']) then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 1,
                func = function()  
                    local winner1 = pseudorandom_element(context.full_hand)
                    local edition = poll_edition('mansion', nil, true, true)
                    winner1:set_edition(edition, true)
                    card_eval_status_text(self, 'extra', nil, nil, nil, {message = "-$3"})
                    ease_dollars(-3)
                    return true
                end
            }))
        end
    end
    -- END MANSION JOKER
    -- START CALENDAR
    SMODS.Sprite:new("j_Calendar", thismod.path, "j_Calendar.png",71,95, "asset_atli"):register();
    local Calendar = SMODS.Joker:new('Calendar Joker', 'Calendar', {}, {x=0, y=0}, {
        name= 'Calendar',
        text= {'Played {C:attention}7{}s have a {C:green}#2# in 7{} chance to give an additional hand', '(#1# Hands left this round)'}
    }, 1, 5, true, true, false, true)
    Calendar:register()

    SMODS.Jokers.j_Calendar.set_ability = function(self,initial,delay_sprites)
        self.ability.handsavailiable = 5
    end
    SMODS.Jokers.j_Calendar.calculate = function(self,context)
        if context.individual then
            if context.other_card:get_id() == 7 then
                if pseudorandom('calendar') < G.GAME.probabilities.normal/7 then
                    if self.ability.handsavailiable ~= 0 then
                        ease_hands_played(1)
                        card_eval_status_text(self, 'extra', nil, nil, nil, {message = "+1 Hand"})
                        self.ability.handsavailiable = self.ability.handsavailiable - 1
                    end
                    
                end
            end
        elseif context.first_hand_drawn then
            self.ability.handsavailiable = 5
        end

    end
    SMODS.Jokers.j_Calendar.loc_def = function(card)
        return {card.ability.handsavailiable,''..(G.GAME and G.GAME.probabilities.normal or 1)}
    end
    -- END CALENDAR
    -- START MICROSCOPE
    SMODS.Sprite:new("j_Microscope", thismod.path, "j_Microscope.png",71,95, "asset_atli"):register();
    local Microscope = SMODS.Joker:new('Microscope Joker', 'Microscope', {mult=3}, {x=0, y=0}, {
        name= 'Temple',
        text= {'{C:red}+#1#{} Mult', 'Played {C:attention}#2#{} of {C:attention}#3#{} give this +3 mult', '{C:inactive}(Card changes at the beginning of each round){}'}
    }, 2, 7, true, true, true, true)
    Microscope:register()
    SMODS.Jokers.j_Microscope.set_ability = function(self,initial,delay_sprites)
        self.ability.targettedsuit = "Spades"
        self.ability.targettedrank = "Ace"
        
    end
    SMODS.Jokers.j_Microscope.calculate = function(self,context)
        if context.individual and not context.blueprint and context.cardarea == G.play then
            if context.other_card:get_id() == self.ability.targettedID and context.other_card:is_suit(self.ability.targettedsuit) then
                self.ability.mult = self.ability.mult + 3
                return {
                    extra = {focus = self, message = '+3 Mult', colour = G.C.MULT},
                    card = self
                }
            end
        end
        if context.first_hand_drawn and not context.blueprint then
            self.ability.targettedrank = 'Ace'
            self.ability.targettedsuit = 'Spades'
            self.ability.targettedID = 1
            local valid_idol_cards = {}
            for k, v in ipairs(G.playing_cards) do
                if v.ability.effect ~= 'Stone Card' then
                    valid_idol_cards[#valid_idol_cards+1] = v
                end
            end
            if valid_idol_cards[1] then 
                local idol_card = pseudorandom_element(valid_idol_cards, pseudoseed('microscope'..G.GAME.round_resets.ante))
                self.ability.targettedrank = idol_card.base.value
                self.ability.targettedID = idol_card.base.id
                self.ability.targettedsuit = idol_card.base.suit
            end
        end
        if SMODS.end_calculate_context(context) then
            return {
                mult_mod = self.ability.mult,
                card = self,
                message = '+' .. self.ability.mult .. ' Mult'
            }
        end
    end
    SMODS.Jokers.j_Microscope.loc_def = function(card)
        return {card.ability.mult,card.ability.targettedrank, card.ability.targettedsuit}
    end
end



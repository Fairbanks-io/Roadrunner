--local Trains = require '__stdlib__/stdlib/event/trains'

ROADRUNNER_OPTIONS_MAP = {
  ["nevergonnagive"] = "nevergonnagive",
  ["none"] = false
}

NEVERGONNAGIVE = "nevergonnagive"

RR_ENABLED = settings.global["roadrunner-enabled"].value
RR_VOLUME = settings.global["roadrunner-volume"].value * 0.01
RR_DISTANCE = settings.global["roadrunner-distance"].value
RR_MOTD = settings.global["roadrunner-motd"].value

local function init_global()
  global = global or {}
  global.paused = {}
end

-- Wipe cooldown table when config changes, in case of any data leaks
script.on_configuration_changed(init_global)
script.on_init(init_global)

-- Detect setting changes during session
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  RR_ENABLED = settings.global["roadrunner-enabled"].value
  RR_VOLUME = settings.global["roadrunner-volume"].value * 0.01
  RR_DISTANCE = settings.global["roadrunner-distance"].value
  RR_CHANCE = settings.global["roadrunner-chance"].value
  RR_MOTD = settings.global["roadrunner-motd"].value
end)

maybe = function(percent)
  assert(percent >= 0 and percent <= 100)
  return percent >= math.random(1, 100)
end

on_tick = function(event)
  -- Run every 30 of 60 ticks per second, or 6x per second.
  if game.tick%30 == 0 then

    -- ##########################################
    -- UN PAUSE TRAINS AFTER CHECKING OUT OF RANGE OF ALL PLAYERS
    -- ##########################################

    -- Iterate global definition of paused trains
    for _, pausedTrain in pairs(global.pausedTrains) do

      -- Make sure pausedTrain has data
      if pausedTrain ~= nil then
        
        -- Assume train should be resumed
        local shouldResume = true

        -- Iterate through each player and make sure they're connected
        for _, player in pairs(game.players) do
          if player.connected == true then

            -- Iterate all locomotives within range of each player
            local locomotives = game.surfaces[1].find_entities_filtered{position = {player.position.x, player.position.y}, radius = RR_DISTANCE, type = {"locomotive", "cargo-wagon"}}
            for _, locomotive in pairs(locomotives) do 

              -- If train is still within range for any player.. do not resume
              if locomotive.train.id == pausedTrain.id then shouldResume = false end

            end
          end
        end

        -- If locomotive of paused train was not found within range of any player, resume it.
        if shouldResume == true then

          -- Resume and remove from paused trains array
          pausedTrain.manual_mode = false
          global.pausedTrains[pausedTrain.id] = nil
        end
      end
    end


    -- ##########################################
    -- PAUSE TRAINS WITHIN RANGE OF ANY PLAYER
    -- ##########################################

    -- Get each player in game.players and make sure they're online.
    for _, player in pairs(game.players) do 
      if player.connected == true then 

        -- Get all locomotives within range of player 
        local locomotives = game.surfaces[1].find_entities_filtered{position = {player.position.x, player.position.y}, radius = RR_DISTANCE, type = {"locomotive", "cargo-wagon"}}

        for _, locomotive in pairs(locomotives) do

          -- Check if train is in automatic mode (todo: And speed > 0)
          if locomotive.train.state ~= defines.train_state.manual_control then          
            -- Set speed to zero FIRST, then set to manual mode
            locomotive.train.speed = 0
            locomotive.train.manual_mode = true

            -- Add train to list of paused trains
            if (not global.pausedTrains[locomotive.train.id]) then global.pausedTrains[locomotive.train.id] = {} end
            global.pausedTrains[locomotive.train.id] = locomotive.train
        
          end

        end
      end
    end
  end
end

-- ####################################################
-- IF PLAYER STILL MANAGES TO DIE, CONGRATULATE THEM
-- ####################################################

player_died = function(event)
  local cause = nil
  -- Check cause of death
  if event and event.cause then
    cause = event.cause.name
  end
  if RR_ENABLED and cause == "locomotive" or cause == "cargo-wagon" then
    game.print(RR_MOTD, {r = 0.5, g = 0, b = 0, a = 0.5})
    game.play_sound({ path = NEVERGONNAGIVE, volume_modifier = RR_VOLUME })
  end
end

-- Watch for tick events
script.on_event(defines.events.on_tick, on_tick)
-- Watch for death events
script.on_event(defines.events.on_entity_died, player_died)
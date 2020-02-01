--local Trains = require '__stdlib__/stdlib/event/trains'

ROADRUNNER_OPTIONS_MAP = {
  ["nevergonnagive"] = "nevergonnagive",
  ["none"] = false
}

NEVERGONNAGIVE = "nevergonnagive"

RR_ENABLED = settings.global["roadrunner-enabled"].value
RR_VOLUME = settings.global["roadrunner-volume"].value * 0.01
RR_DISTANCE = settings.global["roadrunner-distance"].value

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
end)

maybe = function(percent)
  assert(percent >= 0 and percent <= 100)
  return percent >= math.random(1, 100)
end

on_tick = function(event)
  -- Run every 10 of 60 ticks per second, or 6x per second.
  if game.tick%30 == 0 then
    if (not global.pausedTrains) then global.pausedTrains = {} end
    
    for _, player in pairs(game.players) do 
      -- Unpause any previously paused trains if they are outside radius of players    
      for _, pausedTrain in pairs(global.pausedTrains) do
        if pausedTrain ~= nil then
          local x = math.abs(pausedTrain.locomotives.front_movers[1].position.x - player.position.x)
          local y = math.abs(pausedTrain.locomotives.front_movers[1].position.y - player.position.y)
          local distance = (math.max(x, y) * 5 + math.min(x, y) * (2)) / 5
          --game.print("distance of paused train: " .. distance)
          if distance > RR_DISTANCE + 5 then
            pausedTrain.manual_mode = false
            global.pausedTrains[pausedTrain.id] = nil
          end
        end
      end

      -- Get all locomotives within range of player
      local locomotives = game.surfaces[1].find_entities_filtered{position = {player.position.x, player.position.y}, radius = RR_DISTANCE, type = "locomotive"}

      -- Iterate each train within range
      for _, locomotive in pairs(locomotives) do

        -- Automated and moving we turn off automated and set speed to zero
        --if locomotive.train.state ~= defines.train_state.manual_control and locomotive.train.speed > 0 then
        if locomotive.train.state ~= defines.train_state.manual_control then

          --game.print("Pausing train as its too close and moving with speed of: " .. locomotive.train.speed)
          locomotive.train.speed = 0
          locomotive.train.manual_mode = true
          
          --game.print(locomotive.train.id)

          -- Add train to list of paused trains
          if (not global.pausedTrains[locomotive.train.id]) then global.pausedTrains[locomotive.train.id] = {} end
          global.pausedTrains[locomotive.train.id] = locomotive.train
      
        end

      end
    end
  end
end

player_died = function(event)
  game.print("Epstein didn't kill himself", {r = 0.5, g = 0, b = 0, a = 0.5})
  local cause = nil
  -- Check cause of death
  if event and event.cause then
    cause = event.cause.name
  end
  game.print(cause)
  if RR_ENABLED and cause == "locomotive" or cause == "cargo-wagon" then
    game.play_sound
    {
      path = NEVERGONNAGIVE,
      volume_modifier = RR_VOLUME
    }
  end
end

script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_entity_died, player_died)
--local Trains = require '__stdlib__/stdlib/event/trains'

ROADRUNNER_OPTIONS_MAP = {
  ["nevergonnagive"] = "nevergonnagive",
  ["none"] = false
}

NEVERGONNAGIVE = "nevergonnagive"

RR_ENABLED = settings.global["roadrunner-enabled"].value
RR_VOLUME = settings.global["roadrunner-volume"].value * 0.01
RR_DISTANCE = settings.global["roadrunner-distance"].value

-- Wipe cooldown table when config changes, in case of any data leaks
-- the below lines require init_global function defined

local function init_global()
  global = global or {}
  global.paused = {}
end

script.on_configuration_changed(init_global)
script.on_init(init_global)

-- Detect setting changes during session
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  RR_ENABLED = settings.global["roadrunner-enabled"].value
  RR_VOLUME = settings.global["roadrunner-volume"].value * 0.01
  RR_DISTANCE = settings.global["roadrunner-distance"].value
end)

on_tick = function(event)
  --run every half second (or ever 30 of 60 ticks per second) or 2x per second.
  if game.tick%30 == 0 then
    for _, player in pairs(game.players) do 
      local locomotives = game.surfaces[1].find_entities_filtered{position = {player.position.x, player.position.y}, radius = 10, type = "locomotive"}
      
      --local movingTrains = Trains.find_filtered({ surface = "nauvis", state = defines.train_state.on_the_path })

      for _, locomotive in pairs(locomotives) do
        -- check if state of train is moving
        if locomotive.train.state == defines.train_state.on_the_path then
          -- Get chamfer distance - better than Manhattan but cheaper than Euclidean
          local x = math.abs(locomotive.position.x - player.position.x)
          local y = math.abs(locomotive.position.y - player.position.y)
          local distance = (math.max(x, y) * 5 + math.min(x, y) * (2)) / 5
          if distance < 5 then
            game.print("pausing train")
            
            locomotive.train.manual_mode = true
            locomotive.train.speed = 0
            game.print(locomotive.train.id)
            --global.paused[locomotive.train.id] = global.paused[locomotive.train.id] or {}
            --global.paused[locomotive.train.id] = locomotive.train.id
          elseif distance > RR_DISTANCE then
            game.print("resuming..")
            locomotive.train.manual_mode = false
          end
        end
      end
    end
  end
end

player_died = function(event)
  game.print("Epstein didn't kill himself", {r = 0.5, g = 0, b = 0, a = 0.5})
  local cause = event.cause.name or nil
  if RR_ENABLED and cause == "locomotive" or "cargo-wagon" then
    game.play_sound
    {
      path = NEVERGONNAGIVE,
      volume_modifier = RR_VOLUME
    }
  end
end

script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_entity_died, player_died)
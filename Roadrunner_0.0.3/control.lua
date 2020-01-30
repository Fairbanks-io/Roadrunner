ROADRUNNER_OPTIONS_MAP = {
  ["nevergonnagive"] = "nevergonnagive",
  ["none"] = false
}

NEVERGONNAGIVE = "nevergonnagive"

RR_ENABLED = settings.global["roadrunner-enabled"].value
RR_VOLUME = settings.global["roadrunner-volume"].value * 0.01

-- Wipe cooldown table when config changes, in case of any data leaks
script.on_configuration_changed(init_global)
script.on_init(init_global)

-- Detect setting changes during session
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  RR_ENABLED = settings.global["roadrunner-enabled"].value
  RR_VOLUME = settings.global["roadrunner-volume"].value * 0.01
end)

on_player_moved = function(event)
  local player = game.players[event.player_index]
  local locomotives = game.surfaces[1].find_entities_filtered{position = {player.position.x, player.position.y}, radius = 10, type = "locomotive"}
  for i, locomotive in pairs(locomotives) do
    -- Get chamfer distance - better than Manhattan but cheaper than Euclidean
    local x = math.abs(locomotive.position.x - player.position.x)
    local y = math.abs(locomotive.position.y - player.position.y)
    local distance = (math.max(x, y) * 5 + math.min(x, y) * (2)) / 5
    if distance < 5 then
      --locomotive.speed = 0
      game.print("Close to " .. locomotive.name, {r = 0.5, g = 0, b = 0, a = 0.5})
    elseif distance > 5 then
      --locomotive.speed = 100
    end
  end
end

player_died = function(event)
  game.print("Epstein didn't kill himself", {r = 0.5, g = 0, b = 0, a = 0.5})
  if RR_ENABLED then
    game.play_sound
    {
      path = NEVERGONNAGIVE,
      volume_modifier = RR_VOLUME
    }
  end
end

script.on_event(defines.events.on_player_changed_position, on_player_moved)
script.on_event(defines.events.on_entity_died, player_died)
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

script.on_event(defines.events.on_player_changed_position, on_player_moved)
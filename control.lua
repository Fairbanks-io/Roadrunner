on_player_moved = function(event)
  local player = game.players[event.player_index]
  local trains = game.surfaces[1].find_entities_filtered{type = "locomotive"}
  for i, train in pairs(trains) do
    -- Get chamfer distance - better than Manhattan but cheaper than Euclidean
    local x = math.abs(train.position.x - player.position.x)
    local y = math.abs(train.position.y - player.position.y)
    local distance = (math.max(x, y) * 5 + math.min(x, y) * (2)) / 5
    if distance < 5 then
      --train.speed = 0
      game.print("Close to " .. train.name, {r = 0.5, g = 0, b = 0, a = 0.5})
    elseif distance > 5 then
      --train.speed = 100
    end
  end
end

script.on_event(defines.events.on_player_changed_position, on_player_moved)
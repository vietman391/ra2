wave_count = 0
SendWave = function()
    wave_count = wave_count + 1
    Media.DisplayMessage(string.format('Sending wave %d', wave_count))

    local planeCount = wave_count * 4 / 3
    if planeCount >= 5 then
        planeCount = planeCount / 2
    end

    if planeCount >= 10 then
        planeCount = planeCount / 4
    end

    planeCount = math.floor(planeCount)
    local amphibCount = math.floor(planeCount / 3)

    SendAmphibWave(amphibCount)
    SendParadropWave(planeCount)

    local delay = 25 * (60 + planeCount) * 2
    Media.DisplayMessage(string.format('Sending wave %d in %d ticks', wave_count + 1, delay))
    Trigger.AfterDelay(delay, SendWave)
end

SetupStartingForces = function(player)
    local spawn2alpha = { 'a', 'b', 'c', 'd' }
    for _, actor in ipairs(Map.NamedActors) do
        local tag = 'owner_' .. spawn2alpha[player.Spawn]
        if actor.HasTag(tag) then
            actor.Owner = player
        end
    end
end

WorldLoaded = function()
    soviets = Player.GetPlayer("Soviets")
    players = { }
    for i = 0, 4 do
        local player = Player.GetPlayer("Multi" .. i)
        if player then
            players[i] = player
            SetupStartingForces(player)
            if player.Name == "Lonestar AI" then
                ActivateAI(player, i)
            end
        end
    end

    ParaProxy = Actor.Create("powerproxy.paratroopers", false, { Owner = soviets })
    Trigger.AfterDelay(25 * 60 * 4, SendWave)
end

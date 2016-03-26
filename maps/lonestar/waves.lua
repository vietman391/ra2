_antiair = { "flakt", "flakt", "flakt" }
_antitank = { "shk", "shk", "shk" }
_basicinf = { "e2", "e2", "e2", "shk", "flakt" }

_conscripts = { "e2", "e2", "e2", "e2", "e2" }

_mpspawns = {
  ['a'] = mpspawn_a,
  ['b'] = mpspawn_b,
  ['c'] = mpspawn_c,
  ['d'] = mpspawn_d
}

_paradrop_wps = {
    ['a'] = Map.ActorsWithTag('paradrop_a'),
    ['b'] = Map.ActorsWithTag('paradrop_b'),
    ['c'] = Map.ActorsWithTag('paradrop_c'),
    ['d'] = Map.ActorsWithTag('paradrop_d')
}

_amphib_spawn_cells = {
    ['a'] = { wp_spawner_amphib_right_a, wp_spawner_amphib_left_a },
    ['b'] = { wp_spawner_amphib_right_b, wp_spawner_amphib_left_b },
    ['c'] = { wp_spawner_amphib_right_c, wp_spawner_amphib_left_c },
    ['d'] = { wp_spawner_amphib_right_d, wp_spawner_amphib_left_d }
}

_amphib_beach_cells = {
    ['a'] = { wp_back_beach_right_a, wp_back_beach_left_a },
    ['b'] = { wp_back_beach_right_b, wp_back_beach_left_b },
    ['c'] = { wp_back_beach_right_c, wp_back_beach_left_c },
    ['d'] = { wp_back_beach_right_d, wp_back_beach_left_d }
}

_amphib_attack_cells = {
    ['a'] = { wp_back_land_right_a, wp_back_land_left_a, wp_back_land_mid_a },
    ['b'] = { wp_back_land_right_b, wp_back_land_left_b, wp_back_land_mid_b },
    ['c'] = { wp_back_land_right_c, wp_back_land_left_c, wp_back_land_mid_c },
    ['d'] = { wp_back_land_right_d, wp_back_land_left_d, wp_back_land_mid_d }
}

SendAmphibWave = function(amphibCount)
    amphibCount = amphibCount or 3

    for _, player in pairs({ 'a', 'b', 'c' }) do
    --for _, player in pairs({ 'a', 'b', 'c', 'd' }) do
        for i = 0, amphibCount do
            local spawnCell = rand_t(_amphib_spawn_cells[player]).Location
            local returnCell = Map.ClosestEdgeCell(spawnCell)
            local beachCell = rand_t(_amphib_beach_cells[player]).Location
            local attackCell = rand_t(_amphib_attack_cells[player]).Location

            local units1 = copy_t(rand_t({ _antiair, _antitank, _basicinf, _conscripts }))
            local units2 = copy_t(rand_t({ _antiair, _antitank, _basicinf, _conscripts }))

            local units = concat_t(units1, units2)
            units = shuffle_t(units)

            for i, v in ipairs(units) do
              if i % 3 == 0 then
                units[i] = nil
              end
            end

            units = nonil_t(units)

            if spawnCell and beachCell and attackCell then
                _SendAmphib(spawnCell, returnCell, beachCell, attackCell, units)
            end
        end -- amphibCount
    end -- for player
end

_SendAmphib = function(spawnCell, returnCell, targetCell, initialAttackCell, unitComposition)
    Trigger.AfterDelay(0, function()
        local amphib = Actor.Create('sapc', true, {
            Owner = soviets,
            Location = spawnCell,
            Cargo = unitComposition
        })

        amphib.Move(targetCell, 1)

        Trigger.OnPassengerExited(amphib, function(_, passenger)
            passenger.AttackMove(initialAttackCell, 1)
            Trigger.OnIdle(passenger, function(p)
                if not p.IsDead and p.IsInWorld then
                    p.Hunt()
                end
            end)
        
            if not amphib.HasPassengers then
                --Media.DisplayMessage(string.format('%s has no passengers left', tostring(amphib)))
                -- TODO: Instead, we should reuse existing amphibs.
                amphib.Move(returnCell)
                amphib.Destroy()
            end
        end)

        amphib.UnloadPassengers()
    end)
end

SendParadropWave = function(planeCount)
    planeCount = planeCount or 3

    for _, player in pairs({ 'a', 'b', 'c' }) do
        --for _, player in pairs({ 'a', 'b', 'c', 'd' }) do
        for i = 0, planeCount do
            local dropCell = rand_t(_paradrop_wps[player])--.Location
            local mpspawn = _mpspawns[player]

            local units1 = copy_t(rand_t({ _antiair, _antitank, _basicinf, _conscripts }))
            local units2 = copy_t(rand_t({ _antiair, _antitank, _basicinf, _conscripts }))

            local units = concat_t(units1, units2)
            units = shuffle_t(units)

            for i, v in ipairs(units) do
              if i % 3 == 0 then
                units[i] = nil
              end
            end

            units = nonil_t(units)

            _SendParadrop(dropCell, mpspawn, units)
        end
    end
end

_SendParadrop = function(targetCell, initialAttackCell, units)
    local passengers = ParaProxy.SendParatroopers(targetCell.CenterPosition, true, 0, units)
    Utils.Do(passengers, function(passenger)
        passenger.AttackMove(initialAttackCell.Location, 1)
        Trigger.OnIdle(passenger, function(p)
            if not p.IsDead and p.IsInWorld then
                p.AttackMove(initialAttackCell.Location, 1)
            end
        end)
    end)
end
-- end waves

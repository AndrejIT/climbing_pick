-- Climbing tool mod

climbing_pick = {}

climbing_pick.pick_on_use = function(itemstack, user, pointed_thing)
    local pt = pointed_thing
    -- check if pointing at a node
    if not pt then
        return
    end
    if user and pt.type == "object" and pt.ref then
        local pos = user:getpos()
        local target_pos = pt.ref:get_pos()
        if pos and target_pos and vector.distance(pos, target_pos) < 2 then
            local tmp_dir = vector.direction(pos, target_pos)
            local damage = 0
            if pt.ref:is_player() then
                if math.random(1, 100) > 33 then
                    damage = 1
                end
            else
                damage = 5
            end
            pt.ref:punch(user, 1.0,  {
                    full_punch_interval=1.0,
                    damage_groups = {fleshy=damage}
                }, tmp_dir)
            -- visual effect
            minetest.add_particlespawner({
                amount = 20,
                time = 0.2,
                minpos = {x=target_pos.x, y=target_pos.y+0.5, z=target_pos.z},
                maxpos = {x=target_pos.x, y=target_pos.y+0.5, z=target_pos.z},
                minvel = {x=-2, y=0, z=-2},
                maxvel = {x=2, y=0, z=2},
                minacc = {x=0, y=0, z=0},
                maxacc = {x=0, y=0, z=0},
                minexptime = 0.1,
                maxexptime = 1,
                minsize = 0.1,
                maxsize = 1,
                collisiondetection = false,
                vertical = false,
                texture = "default_item_smoke.png"
            })
            local tool_definition = itemstack:get_definition()
            local tool_capabilities = tool_definition.tool_capabilities
            local uses = tool_capabilities.groupcaps.climbing.uses
            itemstack:add_wear(65535/(uses-1))
            -- tool break sound
            if itemstack:get_count() == 0 and tool_definition.sound and tool_definition.sound.breaks then
                minetest.sound_play(tool_definition.sound.breaks, {pos = pt.above, gain = 0.5})
            end
            return itemstack
        end
        return
    elseif pt.type ~= "node" then
        return
    end

    local under = minetest.get_node(pt.under)
    local p = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
    local above = minetest.get_node(p)

    -- return if any of the nodes is not registered
    if not minetest.registered_nodes[under.name] then
        return
    end
    if not minetest.registered_nodes[above.name] then
        return
    end

    -- check if pointing at walkable node
    local nodedef1 = minetest.registered_nodes[under.name]
    if not (nodedef1 and nodedef1.walkable) then
        return
    end

    local plpos = user:get_pos()

    -- if node above is not walkable then limit interaction distance
    local nodedef2 = minetest.registered_nodes[above.name]
    if nodedef2 and nodedef2.walkable then
        if plpos and p and vector.distance(plpos, p) >= 3 then
            return
        end
    end

    local pl = {x=plpos.x, y=plpos.y+3, z=plpos.z}
    local above_player = minetest.get_node(pl)

    -- node above player also must be not walkable
    local nodedef3 = minetest.registered_nodes[above_player.name]
    if nodedef3 and nodedef3.walkable then
        return
    end

    local tool_definition = itemstack:get_definition()
    local tool_capabilities = tool_definition.tool_capabilities
    -- local punch_interval = tool_capabilities.full_punch_interval    -- not sure how to use correctly

    -- sound effect
    minetest.sound_play("default_metal_footstep", {
        pos = pt.under,
        max_hear_distance = 6,
    })
    -- visual effect
    minetest.add_particlespawner({
        amount = 20,
        time = 0.2,
        minpos = {x=pt.under.x, y=pt.under.y+0.5, z=pt.under.z},
        maxpos = {x=pt.under.x, y=pt.under.y+0.5, z=pt.under.z},
        minvel = {x=-2, y=0, z=-2},
        maxvel = {x=2, y=0, z=2},
        minacc = {x=0, y=0, z=0},
        maxacc = {x=0, y=0, z=0},
        minexptime = 0.1,
        maxexptime = 1,
        minsize = 0.1,
        maxsize = 1,
        collisiondetection = false,
        vertical = false,
        texture = "default_item_smoke.png"
    })

    -- no way to set speed of player
    -- emulate it in ugly way
    -- https://github.com/minetest/minetest/issues/1176 :(
    local repetitions = 5
    if tool_capabilities.groupcaps.climbing.maxlevel > 1 then
    	repetitions = repetitions + 2
    end
    if tool_capabilities.groupcaps.climbing.maxlevel > 2 then
    	repetitions = repetitions + 2
    end

    for i = 1, repetitions do
    	plpos.y = plpos.y + 0.2
    	user:moveto(plpos, true)
    end

    if not (creative and creative.is_enabled_for
            and creative.is_enabled_for(user:get_player_name()))
    then
        -- wear tool
        local uses = tool_capabilities.groupcaps.climbing.uses
        itemstack:add_wear(65535/(uses-1))
        -- tool break sound
        if itemstack:get_count() == 0 and tool_definition.sound and tool_definition.sound.breaks then
            minetest.sound_play(tool_definition.sound.breaks, {pos = pt.above, gain = 0.5})
        end
    end
    return itemstack
end

minetest.register_tool("climbing_pick:pick_wood", {
	description = "Wooden climbing pick",
	inventory_image = "handholds_tool_wood.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			climbing = {times={[3]=1.60}, uses=40, maxlevel=1},
		},
	},
	groups = {flammable = 2},
    on_use = function(itemstack, user, pointed_thing)
        return climbing_pick.pick_on_use(itemstack, user, pointed_thing)
    end,
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("climbing_pick:pick_stone", {
	description = "Stone climbing pick",
	inventory_image = "handholds_tool_stone.png",
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level=0,
		groupcaps={
			climbing = {times={[2]=2.0, [3]=1.00}, uses=80, maxlevel=1},
		},
	},
    on_use = function(itemstack, user, pointed_thing)
        return climbing_pick.pick_on_use(itemstack, user, pointed_thing)
    end,
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("climbing_pick:pick_steel", {
	description = "Steel climbing pick",
	inventory_image = "handholds_tool_steel.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			climbing = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=80, maxlevel=2},
		},
	},
    on_use = function(itemstack, user, pointed_thing)
        return climbing_pick.pick_on_use(itemstack, user, pointed_thing)
    end,
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("climbing_pick:pick_bronze", {
	description = "Bronze climbing pick",
	inventory_image = "handholds_tool_bronze.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			climbing = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=120, maxlevel=2},
		},
	},
    on_use = function(itemstack, user, pointed_thing)
        return climbing_pick.pick_on_use(itemstack, user, pointed_thing)
    end,
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("climbing_pick:pick_mese", {
	description = "Mese climbing pick",
	inventory_image = "handholds_tool_mese.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=3,
		groupcaps={
			climbing = {times={[1]=2.4, [2]=1.2, [3]=0.60}, uses=80, maxlevel=3},
		},
	},
    on_use = function(itemstack, user, pointed_thing)
        return climbing_pick.pick_on_use(itemstack, user, pointed_thing)
    end,
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("climbing_pick:pick_diamond", {
	description = "Diamond climbing pick",
	inventory_image = "handholds_tool_diamond.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			climbing = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=120, maxlevel=3},
		},
	},
    on_use = function(itemstack, user, pointed_thing)
        return climbing_pick.pick_on_use(itemstack, user, pointed_thing)
    end,
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
	output = "climbing_pick:pick_wood",
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:stick', '', ''},
		{'group:stick', '', ''},
	},
})

minetest.register_craft({
	output = "climbing_pick:pick_stone",
	recipe = {
		{'group:stone', 'group:stone', 'group:stone'},
		{'group:stick', '', ''},
		{'group:stick', '', ''},
	},
})

minetest.register_craft({
	output = "climbing_pick:pick_steel",
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'group:stick', '', ''},
		{'group:stick', '', ''},
	},
})

minetest.register_craft({
	output = "climbing_pick:pick_bronze",
	recipe = {
		{'default:bronze_ingot', 'default:bronze_ingot', 'default:bronze_ingot'},
		{'group:stick', '', ''},
		{'group:stick', '', ''},
	},
})

minetest.register_craft({
	output = "climbing_pick:pick_mese",
	recipe = {
		{'default:mese_crystal', 'default:mese_crystal', 'default:mese_crystal'},
		{'group:stick', '', ''},
		{'group:stick', '', ''},
	},
})

minetest.register_craft({
	output = "climbing_pick:pick_diamond",
	recipe = {
		{'default:diamond', 'default:diamond', 'default:diamond'},
		{'group:stick', '', ''},
		{'group:stick', '', ''},
	},
})

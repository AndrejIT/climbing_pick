-- Climbing tool mod

climbing_pick = {}

climbing_pick.pick_on_use = function(itemstack, user, pointed_thing)
    local pt = pointed_thing
    -- check if pointing at a node
    if not pt then
        return
    end
    if pt.type ~= "node" then
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

    -- node above must be not walkable
    local nodedef2 = minetest.registered_nodes[above.name]
    if nodedef2 and nodedef2.walkable then
        return
    end

    local tool_definition = itemstack:get_definition()
    local tool_capabilities = tool_definition.tool_capabilities
    -- local punch_interval = tool_capabilities.full_punch_interval    -- not sure how to use correctly

    -- no way to set speed of player
    -- emulate it in ugly way
    -- https://github.com/minetest/minetest/issues/1176 :(
    local plpos = user:get_pos()
    plpos.y = plpos.y + 0.2
    user:moveto(plpos, true)
    plpos = user:get_pos()
    plpos.y = plpos.y + 0.2
    user:moveto(plpos, true)
    plpos = user:get_pos()
    plpos.y = plpos.y + 0.2
    user:moveto(plpos, true)
    plpos = user:get_pos()
    plpos.y = plpos.y + 0.2
    user:moveto(plpos, true)
    plpos = user:get_pos()
    plpos.y = plpos.y + 0.2
    user:moveto(plpos, true)
    if tool_capabilities.groupcaps.climbing.maxlevel > 1 then
        plpos = user:get_pos()
        plpos.y = plpos.y + 0.2
        user:moveto(plpos, true)
        plpos = user:get_pos()
        plpos.y = plpos.y + 0.2
        user:moveto(plpos, true)
        if tool_capabilities.groupcaps.climbing.maxlevel > 2 then
            plpos = user:get_pos()
            plpos.y = plpos.y + 0.2
            user:moveto(plpos, true)
            plpos = user:get_pos()
            plpos.y = plpos.y + 0.2
            user:moveto(plpos, true)
        end
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

--
--LION
--
local S = ...

local pet_name = "lion"
local scale_model = 2.3
petz.lion = {}
local mesh = 'petz_lion.b3d'	
local textures = {"petz_lion.png"}	
local collisionbox = {-0.5, -0.75*scale_model, -0.5, 0.375, -0.375, 0.375}

minetest.register_entity("petz:"..pet_name,{          
	--Petz specifics	
	type = "lion",	
	init_tamagochi_timer = true,	
	is_pet = true,
	has_affinity = true,
	is_wild = true,
	attack_player = true,
	give_orders = true,
	can_be_brushed = true,
	capture_item = "lasso",
	follow = petz.settings.lion_follow,	
	drops = {
		{name = "petz:bone", chance = 5, min = 1, max = 1,},
	},
	rotate = petz.settings.rotate,
	physical = true,
	stepheight = 0.1,	--EVIL!
	collide_with_objects = true,
	collisionbox = collisionbox,
	visual = petz.settings.visual,
	mesh = mesh,
	textures = textures,
	visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model},
	static_save = true,
	get_staticdata = mobkit.statfunc,
	-- api props
	springiness= 0,
	buoyancy = 0.5, -- portion of hitbox submerged
	max_speed = 2.3,
	jump_height = 1.5,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 30,  		
	
	attack={range=0.5, damage_groups={fleshy=9}},	
	animation = {
		walk={range={x=1, y=12}, speed=20, loop=true},	
		run={range={x=13, y=25}, speed=20, loop=true},	
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
			{range={x=82, y=94}, speed=5, loop=true},		
		},	
		sit = {range={x=60, y=65}, speed=5, loop=false},
	},
	sounds = {
		misc = "petz_lion_roar",
		moaning = "petz_lion_moaning",
	},
	
	--punch_start = 83, stand4_end = 95,
	
	brainfunc = petz.predator_brain,
	
	on_activate = function(self, staticdata, dtime_s) --on_activate, required
		mobkit.actfunc(self, staticdata, dtime_s)
		petz.set_initial_properties(self, staticdata, dtime_s)
	end,
	
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)		
		petz.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
	end,
	
	on_rightclick = function(self, clicker)
		petz.on_rightclick(self, clicker)
	end,
	
	on_step = function(self, dtime)	
		petz.stepfunc(self, dtime) -- required
		petz.on_step(self, dtime)
	end,
    
})

petz:register_egg("petz:lion", S("Lion"), "petz_spawnegg_lion.png", 0)

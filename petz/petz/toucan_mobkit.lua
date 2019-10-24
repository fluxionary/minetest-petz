local S = ...

local pet_name = "toucan"
local scale_model = 0.7
local mesh = 'petz_toucan.b3d'	
local textures= {"petz_toucan.png", "petz_toucan2.png"}
local collisionbox = {-0.35, -0.75*scale_model, -0.28, 0.35, 0.35, 0.28}

minetest.register_entity("petz:"..pet_name,{          
	--Petz specifics	
	type = "toucan",	
	init_tamagochi_timer = true,	
	is_pet = true,
	can_fly = true,	
	max_height = 5,
	has_affinity = true,
	is_wild = false,
	feathered = true,
	give_orders = true,
	can_be_brushed = true,
	capture_item = "net",
	follow = petz.settings.toucan_follow,
	drops = {
	},
	--automatic_face_movement_dir = 0.0,
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
	max_speed = 2.5,
	jump_height = 2.0,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 12,
	
	attack={range=0.5, damage_groups={fleshy=3}},	
	animation = {
		walk={range={x=1, y=12}, speed=20, loop=true},	
		run={range={x=13, y=25}, speed=20, loop=true},	
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
			{range={x=60, y=70}, speed=5, loop=true},		
			{range={x=71, y=91}, speed=5, loop=true},	
		},	
		fly={range={x=92, y=98}, speed=25, loop=true},	
		stand_fly={range={x=92, y=98}, speed=25, loop=true},	
	},
	sounds = {
		misc = "petz_toucan_croak",
		moaning = "petz_toucan_moaning",
	},
	
	brainfunc = petz.herbivore_brain,
	
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

petz:register_egg("petz:toucan", S("Toucan"), "petz_spawnegg_toucan.png", false)

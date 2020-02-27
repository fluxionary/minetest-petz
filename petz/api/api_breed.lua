local modpath, S = ...

petz.breed = function(self, clicker, wielded_item, wielded_item_name)
	if self.is_rut == false and self.is_pregnant == false then
		wielded_item:take_item()
		clicker:set_wielded_item(wielded_item)
		self.is_rut = true
		mobkit.remember(self, "is_rut", self.is_rut)
		petz.do_particles_effect(self.object, self.object:get_pos(), "heart")
		petz.do_sound_effect("object", self.object, "petz_"..self.type.."_moaning")
	else
		if self.is_rut then
			minetest.chat_send_player(clicker:get_player_name(), S("This animal is already rut."))			
		else
			minetest.chat_send_player(clicker:get_player_name(), S("This animal is already pregnant."))
		end
	end
end

petz.pony_breed = function(self, clicker, wielded_item, wielded_item_name)
	if wielded_item_name == "petz:glass_syringe" and self.is_male== true then		
		local new_wielded_item = ItemStack("petz:glass_syringe_sperm")
		local meta = new_wielded_item:get_meta()
		meta:set_string("petz_type", self.type)
		meta:set_int("max_speed_forward", self.max_speed_forward)
		meta:set_int("max_speed_reverse", self.max_speed_reverse)
		meta:set_int("accel", self.accel)
		clicker:set_wielded_item(new_wielded_item)
	elseif wielded_item_name == "petz:glass_syringe_sperm" and self.is_male== false then	 
		local meta = wielded_item:get_meta()
		local petz_type = meta:get_string("petz_type")
		if self.is_pregnant == false and self.pregnant_count > 0 and self.type == petz_type then
			self.is_pregnant = mobkit.remember(self, "is_pregnant", true)
			local pregnant_count = self.pregnant_count - 1
			mobkit.remember(self, "pregnant_count", pregnant_count)	
			local max_speed_forward = meta:get_int("max_speed_forward")
			local max_speed_reverse = meta:get_int("max_speed_reverse")
			local accel = meta:get_int("accel")	
			local father_veloc_stats = {}
			father_veloc_stats["max_speed_forward"] = max_speed_forward
			father_veloc_stats["max_speed_reverse"] = max_speed_reverse
			father_veloc_stats["accel"] = accel			
			self.father_veloc_stats = mobkit.remember(self, "father_veloc_stats", father_veloc_stats)
			petz.do_particles_effect(self.object, self.object:get_pos(), "pregnant".."_"..self.type)
			clicker:set_wielded_item("petz:glass_syringe")	
		end
	end
end

petz.childbirth = function(self)
	local pos = self.object:get_pos()		
	self.is_pregnant = mobkit.remember(self, "is_pregnant", false)
	self.pregnant_time = mobkit.remember(self, "pregnant_time", 0.0)
	local baby_properties = {}
	baby_properties["baby_born"] = true
	if self.father_genes then
		baby_properties["gen1_father"] = self.father_genes["gen1"]
		baby_properties["gen2_father"] = self.father_genes["gen2"]
	else
		baby_properties["gen1_father"] = math.random(1, #self.skin_colors-1)
		baby_properties["gen2_father"] = math.random(1, #self.skin_colors-1)
	end
	if self and self.genes then
		baby_properties["gen1_mother"] = self.genes["gen1"]
		baby_properties["gen2_mother"] = self.genes["gen2"]
	else
		baby_properties["gen1_mother"] = math.random(1, #self.skin_colors-1)
		baby_properties["gen2_mother"] = math.random(1, #self.skin_colors-1)
	end
	local baby_type = "petz:"..self.type
	if self.type == "elephant" then -- female elephants have "elephant" as type
		if math.random(1, 2) == 1 then
			baby_type = "petz:elephant_female" --could be a female baby elephant
		end
	end
	local baby = minetest.add_entity(pos, baby_type, minetest.serialize(baby_properties))
	local baby_entity = baby:get_luaentity()
	baby_entity.is_baby = true
	mobkit.remember(baby_entity, "is_baby", baby_entity.is_baby)
	if not(self.owner== nil) and not(self.owner== "") then					
		baby_entity.tamed = true
		mobkit.remember(baby_entity, "tamed", baby_entity.tamed)
		baby_entity.owner = self.owner
		mobkit.remember(baby_entity, "owner", baby_entity.owner)
	end	
	return baby_entity
end

local function fuzzy_average(v1, v2)
	v1 = v1 or 1
	local fuzz = math.random(-1, 1)
	local tie_breaker = math.random(2) == 1 and -0.1 or 0.1
	local new_v = petz.round(((v1 + v2) / 2) + tie_breaker, 0) + fuzz
        return math.max(0, math.min(new_v, 10))
end

petz.pregnant_timer = function(self, dtime)
	self.pregnant_time = mobkit.remember(self, "pregnant_time", self.pregnant_time + dtime) 
	if self.pregnant_time >= petz.settings.pregnancy_time then
		local baby_entity = petz.childbirth(self)
		if self.is_mountable == true then		
			--Set the genetics accordingly the father and the mother
			local father_veloc_stats = self.father_veloc_stats
			baby_entity.max_speed_forward = fuzzy_average(father_veloc_stats.max_speed_forward, self.max_speed_forward)
			mobkit.remember(baby_entity, "max_speed_forward", baby_entity.max_speed_forward)
			baby_entity.max_speed_reverse = fuzzy_average(father_veloc_stats.max_speed_reverse, self.max_speed_reverse)
			mobkit.remember(baby_entity, "max_speed_reverse", baby_entity.max_speed_reverse)
			baby_entity.accel = fuzzy_average(father_veloc_stats.accel, self.accel)
			mobkit.remember(baby_entity, "accel", baby_entity.accel)				
		end
	end
end

petz.init_growth = function(self)
    minetest.after(petz.settings.growth_time, function(self)         
		if mobkit.is_alive(self) then
			self.is_baby = false
			mobkit.remember(self, "is_baby", self.is_baby)
			petz.set_properties(self, {
				jump = false,
				is_baby = false,
				visual_size = self.visual_size,
				collisionbox = self.collisionbox 
			})		
		end
    end, self)
end

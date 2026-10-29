-- Story quest definitions.
--
-- Objective types:
--   produce  {item=, count=} or {fluid=, count=}  total produced by the force (all surfaces)
--   research {tech=}
--   build    {entity=, count=}                     entities currently owned by the force
--            {entity=, kind=, count=}             any entity of prototype type `kind` counts
--            {entity=, kind=, types=, count=}     `types` limits the counted prototype types
--   rocket   {count=}                             rockets launched by the force
--   visit    {planet=}                            a player of the force stood on the planet
--   reach    {location=}                          a platform of the force reached the space location
--
-- Mod compatibility:
--   The book is assembled from groups; a group is added only when every named mod is
--   active (`add_group`), so chapters and quests for missing mods are omitted entirely
--   and the numbering adapts automatically.
--   Objectives and rewards may carry an `alternatives` list of prototype names: the
--   first valid prototype is used, so overhauls that rename or replace content
--   (e.g. Krastorio 2 replacing rifle ammo) keep the quest playable.

local chapters = {}
local quests = {}

local function add_group(mods, group)
  if mods then
    for _, mod in ipairs(mods) do
      if not script.active_mods[mod] then return end
    end
  end
  for _, chapter in ipairs(group.chapters) do chapters[#chapters + 1] = chapter end
  for _, quest in ipairs(group.quests) do quests[#quests + 1] = quest end
end

-- Chapter numbers as Roman numerals, built at runtime.

local ROMAN = {
  { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" },
  { 100, "C" }, { 90, "XC" }, { 50, "L" }, { 40, "XL" },
  { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" },
}

local function to_roman(number)
  if number <= 0 or number >= 4000 then return tostring(number) end
  local numeral = {}
  for _, pair in ipairs(ROMAN) do
    local value, digits = pair[1], pair[2]
    while number >= value do
      numeral[#numeral + 1] = digits
      number = number - value
    end
  end
  return table.concat(numeral)
end

---------------------------------------------------------------------------
-- Base game: crash landing.
---------------------------------------------------------------------------

add_group(nil, {
  chapters = {
    { id = "landing", icon = "item/burner-mining-drill" },
  },
  quests = {
    -- Chapter: crash landing
    { id = "wake", chapter = "landing", requires = {},
      objectives = {
        { type = "produce", item = "iron-plate", count = 50 },
        { type = "produce", item = "copper-plate", count = 20 },
      } },
    { id = "drills", chapter = "landing",
      objectives = {
        { type = "build", entity = "burner-mining-drill", kind = "mining-drill", count = 6 },
        { type = "build", entity = "stone-furnace", kind = "furnace", types = { "furnace", "assembling-machine" }, count = 6 },
      },
      rewards = { { name = "wood", count = 50 } } },
    { id = "power", chapter = "landing",
      objectives = {
        { type = "build", entity = "offshore-pump", kind = "offshore-pump", count = 1 },
        { type = "build", entity = "boiler", kind = "boiler", count = 1 },
        { type = "build", entity = "steam-engine", kind = "generator", count = 2 },
      },
      rewards = { { name = "small-electric-pole", count = 20 } } },
    -- Krastorio: the first automation research is gated behind automation
    -- cores, so the cores belong in the first chapter. Skipped without K2.
    { id = "k2-basics", chapter = "landing", requires = { "power" },
      objectives = {
        { type = "research", tech = "kr-automation-core" },
        { type = "produce", item = "kr-automation-core", count = 10 },
        { type = "build", entity = "kr-crusher", count = 2 },
      } },
    { id = "lab", chapter = "landing",
      objectives = {
        { type = "build", entity = "lab", kind = "lab", count = 1 },
        { type = "research", tech = "automation" },
      } },
  },
})

---------------------------------------------------------------------------
-- Base game: automation, defense and black gold.
---------------------------------------------------------------------------

add_group(nil, {
  chapters = {
    { id = "automation", icon = "item/assembling-machine-1" },
    { id = "defense",    icon = "item/gun-turret" },
    { id = "oil",        icon = "fluid/crude-oil" },
  },
  quests = {
    -- Chapter: automation
    { id = "red-science", chapter = "automation", requires = { "lab", "k2-basics" },
      objectives = {
        { type = "build", entity = "assembling-machine-1", kind = "assembling-machine", count = 5 },
        { type = "produce", item = "automation-science-pack", count = 100 },
      },
      rewards = { { name = "assembling-machine-1", count = 5 } } },
    { id = "belts", chapter = "automation",
      objectives = {
        { type = "research", tech = "logistics" },
        { type = "build", entity = "electric-mining-drill", kind = "mining-drill", count = 10 },
        { type = "produce", item = "transport-belt", count = 300 },
      },
      rewards = { { name = "inserter", count = 20 } } },
    { id = "green-science", chapter = "automation",
      objectives = {
        { type = "research", tech = "logistic-science-pack" },
        { type = "produce", item = "logistic-science-pack", count = 200 },
      },
      rewards = { { name = "assembling-machine-2", count = 4 } } },

    -- Chapter: defense
    { id = "turrets", chapter = "defense", requires = { "red-science" },
      objectives = {
        { type = "research", tech = "gun-turret" },
        { type = "build", entity = "gun-turret", kind = "turret", types = { "ammo-turret", "electric-turret", "fluid-turret" }, count = 6 },
        { type = "produce", item = "kr-rifle-magazine", alternatives = { "firearm-magazine" }, count = 200 },
      },
      rewards = { { name = "kr-rifle-magazine", alternatives = { "firearm-magazine" }, count = 100 } } },
    { id = "walls", chapter = "defense",
      objectives = {
        { type = "research", tech = "stone-wall" },
        { type = "build", entity = "stone-wall", kind = "wall", count = 100 },
        { type = "research", tech = "military-2" },
      },
      rewards = { { name = "piercing-rounds-magazine", count = 100 } } },

    -- Chapter: black gold
    { id = "oil", chapter = "oil", requires = { "green-science" },
      objectives = {
        { type = "research", tech = "oil-processing" },
        { type = "build", entity = "pumpjack", count = 1 },
        { type = "build", entity = "oil-refinery", count = 1 },
        { type = "produce", fluid = "petroleum-gas", count = 10000 },
      } },
    -- Krastorio refines silicon from quartz rather than mining ore; the
    -- filtration tech follows the early fluids tier, so it slots in after
    -- black gold. Skipped without K2.
    { id = "k2-silicon", chapter = "oil", requires = { "oil", "k2-basics" },
      objectives = {
        { type = "research", tech = "kr-silicon-processing" },
        { type = "build", entity = "kr-filtration-plant", count = 2 },
        { type = "produce", item = "kr-silicon", count = 200 },
      } },
    { id = "plastic", chapter = "oil",
      objectives = {
        { type = "produce", item = "plastic-bar", count = 200 },
        { type = "produce", item = "advanced-circuit", count = 100 },
      } },
    { id = "military-science", chapter = "oil", requires = { "walls", "plastic" },
      objectives = {
        { type = "research", tech = "military-science-pack" },
        { type = "produce", item = "military-science-pack", count = 100 },
      },
      rewards = { { name = "grenade", count = 20 } } },
    { id = "blue-science", chapter = "oil", requires = { "plastic" },
      objectives = {
        { type = "research", tech = "chemical-science-pack" },
        { type = "produce", item = "chemical-science-pack", count = 200 },
      } },
  },
})

---------------------------------------------------------------------------
-- Krastorio 2: rare metals, after blue science.
---------------------------------------------------------------------------

add_group({ "Krastorio2" }, {
  chapters = {
    { id = "k2-rare-metals", icon = "item/kr-rare-metals" },
  },
  quests = {
    { id = "k2-rare-metals", chapter = "k2-rare-metals", requires = { "k2-silicon", "blue-science" },
      objectives = {
        { type = "research", tech = "kr-rare-metal-mining" },
        { type = "research", tech = "kr-rare-metal-processing" },
        { type = "produce", item = "kr-rare-metals", count = 300 },
      } },
  },
})

---------------------------------------------------------------------------
-- Base game: grand networks and the last sciences.
---------------------------------------------------------------------------

add_group(nil, {
  chapters = {
    { id = "networks", icon = "item/roboport" },
    { id = "science",  icon = "item/utility-science-pack" },
  },
  quests = {
    -- Chapter: grand networks
    { id = "rails", chapter = "networks", requires = { "blue-science" },
      objectives = {
        { type = "research", tech = "railway" },
        { type = "build", entity = "locomotive", count = 1 },
        { type = "build", entity = "train-stop", count = 2 },
      },
      rewards = { { name = "rail", count = 100 } } },
    { id = "solar", chapter = "networks", requires = { "blue-science" },
      objectives = {
        { type = "research", tech = "solar-energy" },
        { type = "build", entity = "solar-panel", kind = "solar-panel", count = 50 },
        { type = "build", entity = "accumulator", kind = "accumulator", count = 30 },
      } },
    { id = "robots", chapter = "networks", requires = { "blue-science" },
      objectives = {
        { type = "research", tech = "construction-robotics" },
        { type = "build", entity = "roboport", count = 1 },
        { type = "produce", item = "construction-robot", count = 20 },
        { type = "research", tech = "logistic-robotics" },
      },
      rewards = { { name = "construction-robot", count = 10 } } },

    -- Chapter: the last sciences
    { id = "purple-science", chapter = "science", requires = { "blue-science", "rails" },
      objectives = {
        { type = "research", tech = "production-science-pack" },
        { type = "produce", item = "production-science-pack", count = 200 },
      } },
    { id = "yellow-science", chapter = "science", requires = { "blue-science", "robots" },
      objectives = {
        { type = "research", tech = "utility-science-pack" },
        { type = "produce", item = "utility-science-pack", count = 200 },
      } },
    { id = "modules", chapter = "science", requires = { "purple-science" },
      objectives = {
        { type = "research", tech = "productivity-module" },
        { type = "produce", item = "productivity-module", count = 20 },
        { type = "build", entity = "beacon", count = 4 },
      },
      rewards = { { name = "speed-module", count = 4 } } },
    { id = "nuclear", chapter = "science", requires = { "blue-science", "solar" },
      objectives = {
        { type = "research", tech = "nuclear-power" },
        { type = "produce", item = "uranium-235", count = 10 },
        { type = "build", entity = "nuclear-reactor", count = 1 },
      } },
  },
})

---------------------------------------------------------------------------
-- Krastorio 2: imersium, after purple science.
---------------------------------------------------------------------------

add_group({ "Krastorio2" }, {
  chapters = {
    { id = "k2-imersium", icon = "item/kr-imersium-plate" },
  },
  quests = {
    { id = "k2-imersium", chapter = "k2-imersium", requires = { "purple-science" },
      objectives = {
        { type = "research", tech = "kr-imersium-processing" },
        { type = "produce", item = "kr-imersium-plate", count = 250 },
        { type = "research", tech = "kr-advanced-tech-card" },
      } },
    -- In the spaced-out variant the advanced furnace research only becomes
    -- viable after Vulcanus science, so furnaces are their own later stage.
    { id = "k2-advanced-furnace", chapter = "k2-imersium",
      requires = { "k2-imersium", "vulcanus-science" },
      objectives = {
        { type = "research", tech = "kr-advanced-furnace" },
        { type = "build", entity = "kr-advanced-furnace", count = 2 },
      } },
  },
})

---------------------------------------------------------------------------
-- Base game: to the stars.
---------------------------------------------------------------------------

-- With Muluna installed the moon's own laboratories produce the space
-- science directly, so the orbit-platform objective is not needed there.
local space_science_quests = {}
if not script.active_mods["planet-muluna"] then
  space_science_quests[1] = {
    id = "space-science", chapter = "stars", requires = { "launch" },
    objectives = {
      -- With K2SO installed vanilla space science is reworked; the Muluna
      -- interstellar pack is the direct analog and keeps the quest alive.
      { type = "produce", item = "space-science-pack", alternatives = { "interstellar-science-pack" }, count = 1000 },
    },
  }
end

add_group(nil, {
  chapters = {
    { id = "stars", icon = "item/rocket-silo" },
  },
  quests = {
    -- Chapter: to the stars
    { id = "silo", chapter = "stars", requires = { "purple-science", "yellow-science" },
      objectives = {
        { type = "research", tech = "rocket-silo" },
        { type = "build", entity = "rocket-silo", count = 1 },
        { type = "produce", item = "rocket-part", count = 50 },
      } },
    { id = "launch", chapter = "stars", requires = { "silo" },
      objectives = {
        { type = "rocket", count = 1 },
      } },
    space_science_quests[1],
  },
})

---------------------------------------------------------------------------
-- Space Age: orbit. Platforms and thrusters come before visiting Muluna,
-- since flying to the moon needs a fueled platform. Space science is not
-- required here: with Muluna installed it is produced on the moon, which
-- would deadlock the platform build.
---------------------------------------------------------------------------

-- Muluna is an island in the sky, so with the moon installed the platform
-- is just the ride there and the asteroid collectors and crushers are not
-- part of the first platform.
local platform_objectives = {
  { type = "research", tech = "space-platform" },
  { type = "build", entity = "space-platform-hub", count = 1 },
}
if not script.active_mods["planet-muluna"] then
  platform_objectives[#platform_objectives + 1] = { type = "build", entity = "asteroid-collector", count = 2 }
  platform_objectives[#platform_objectives + 1] = { type = "build", entity = "crusher", count = 2 }
end

add_group({ "space-age" }, {
  chapters = {
    { id = "orbit", icon = "item/space-platform-hub" },
  },
  quests = {
    { id = "platform", chapter = "orbit", requires = { "launch" },
      objectives = platform_objectives },
    { id = "thrusters", chapter = "orbit", requires = { "platform" },
      objectives = {
        { type = "research", tech = "space-platform-thruster" },
        { type = "build", entity = "thruster", count = 2 },
      } },
  },
})

-- The spaced-out Krastorio variant hides the cryolab entirely, so the
-- cryolab objectives only exist without it.
local cryolab_objectives = {}
if not script.active_mods["Krastorio2-spaced-out"] then
  cryolab_objectives = {
    { type = "research", tech = "cryolab" },
    { type = "build", entity = "cryolab", count = 1 },
  }
end

---------------------------------------------------------------------------
-- Muluna, moon of Nauvis.
---------------------------------------------------------------------------

add_group({ "planet-muluna" }, {
  chapters = {
    { id = "muluna", icon = "space-location/muluna" },
  },
  quests = {
    { id = "muluna-arrival", chapter = "muluna", requires = { "thrusters" },
      objectives = {
        { type = "research", tech = "planet-discovery-muluna" },
        { type = "visit", planet = "muluna" },
        { type = "produce", item = "anorthite-chunk", count = 100 },
      } },
    -- The moon has no air: power comes from vacuum boilers burning fuel in
    -- controlled combustion, and the steam crusher is the entry into lunar
    -- industry (its item is even an ingredient of the lunar science pack).
    { id = "muluna-power", chapter = "muluna", requires = { "muluna-arrival" },
      objectives = {
        { type = "research", tech = "muluna-advanced-boiler" },
        { type = "build", entity = "muluna-advanced-boiler", count = 2 },
        { type = "research", tech = "muluna-steam-crusher" },
        { type = "build", entity = "muluna-steam-crusher", count = 2 },
      } },
    { id = "muluna-regolith", chapter = "muluna", requires = { "muluna-power" },
      objectives = {
        { type = "research", tech = "muluna-regolith-digging" },
        { type = "research", tech = "muluna-anorthite-processing" },
        { type = "produce", item = "muluna-lunar-regolith", count = 200 },
        { type = "produce", item = "aluminum-plate", count = 300 },
      } },
    { id = "muluna-silicon", chapter = "muluna", requires = { "muluna-regolith" },
      objectives = {
        { type = "research", tech = "muluna-silicon-processing" },
        -- K2SO converts silicon into its kr- variant.
        { type = "produce", item = "silicon", alternatives = { "kr-silicon" }, count = 200 },
        { type = "produce", item = "silicon-carbide", count = 100 },
        { type = "produce", item = "silicon-cell", count = 50 },
      } },
    { id = "muluna-science", chapter = "muluna", requires = { "muluna-silicon" },
      objectives = {
        { type = "research", tech = "muluna-telescope" },
        { type = "build", entity = "muluna-telescope", count = 1 },
        cryolab_objectives[1],
        cryolab_objectives[2],
        { type = "produce", item = "interstellar-science-pack", count = 200 },
      } },
  },
})

---------------------------------------------------------------------------
-- Space Age: the volcanic planet.
---------------------------------------------------------------------------

add_group({ "space-age" }, {
  chapters = {
    { id = "vulcanus", icon = "space-location/vulcanus" },
  },
  quests = {
    { id = "vulcanus-landing", chapter = "vulcanus", requires = { "thrusters" },
      objectives = {
        { type = "research", tech = "planet-discovery-vulcanus" },
        { type = "visit", planet = "vulcanus" },
        { type = "research", tech = "foundry" },
        { type = "build", entity = "foundry", count = 1 },
      } },
    { id = "vulcanus-science", chapter = "vulcanus",
      objectives = {
        { type = "build", entity = "big-mining-drill", count = 2 },
        { type = "produce", item = "tungsten-plate", count = 200 },
        { type = "produce", item = "metallurgic-science-pack", count = 500 },
      } },
  },
})

---------------------------------------------------------------------------
-- Cerys, moon of Fulgora.
---------------------------------------------------------------------------

add_group({ "Cerys-Moon-of-Fulgora" }, {
  chapters = {
    { id = "cerys", icon = "space-location/cerys" },
  },
  quests = {
    { id = "cerys-arrival", chapter = "cerys", requires = { "thrusters" },
      objectives = {
        { type = "research", tech = "moon-discovery-cerys" },
        { type = "visit", planet = "cerys" },
        { type = "produce", item = "cerys-nuclear-scrap", count = 100 },
      } },
    -- The reverse-engineered science pack consumes ancient structure repair
    -- parts, so the parts are produced in the same stage as the pack.
    { id = "cerys-science", chapter = "cerys", requires = { "cerys-arrival", "nuclear" },
      objectives = {
        { type = "research", tech = "cerys-nitrogen-rich-mineral-processing" },
        { type = "research", tech = "cerys-nuclear-scrap-recycling" },
        { type = "research", tech = "cerys-fulgoran-cryogenics" },
        { type = "produce", item = "ancient-structure-repair-part", count = 50 },
        { type = "produce", item = "cerysian-science-pack", count = 200 },
      } },
    -- The late structure repair researches unlock the reactor scaffolding.
    { id = "cerys-ancient", chapter = "cerys", requires = { "cerys-science" },
      objectives = {
        { type = "research", tech = "cerys-advanced-structure-repair" },
        { type = "research", tech = "cerys-space-science-pack-from-methane-ice" },
      } },
    { id = "cerys-reactor", chapter = "cerys", requires = { "cerys-ancient" },
      objectives = {
        { type = "research", tech = "cerys-reactor-fuel" },
        { type = "research", tech = "cerys-mixed-oxide-reactors" },
        { type = "build", entity = "cerys-mixed-oxide-reactor", count = 1 },
        { type = "produce", item = "mixed-oxide-fuel-cell", count = 25 },
      } },
  },
})

---------------------------------------------------------------------------
-- Space Age: the electromagnetic and living planets.
---------------------------------------------------------------------------

add_group({ "space-age" }, {
  chapters = {
    { id = "fulgora", icon = "space-location/fulgora" },
    { id = "gleba",   icon = "space-location/gleba" },
  },
  quests = {
    -- Chapter: Fulgora
    { id = "fulgora-landing", chapter = "fulgora", requires = { "thrusters" },
      objectives = {
        { type = "research", tech = "planet-discovery-fulgora" },
        { type = "visit", planet = "fulgora" },
        { type = "build", entity = "recycler", count = 4 },
        { type = "build", entity = "lightning-rod", count = 4 },
      } },
    { id = "fulgora-science", chapter = "fulgora",
      objectives = {
        { type = "build", entity = "electromagnetic-plant", count = 1 },
        { type = "produce", item = "holmium-plate", count = 200 },
        { type = "produce", item = "electromagnetic-science-pack", count = 500 },
      } },

    -- Chapter: Gleba
    { id = "gleba-landing", chapter = "gleba", requires = { "thrusters" },
      objectives = {
        { type = "research", tech = "planet-discovery-gleba" },
        { type = "visit", planet = "gleba" },
        { type = "build", entity = "agricultural-tower", count = 4 },
        { type = "build", entity = "biochamber", count = 2 },
      } },
    { id = "gleba-science", chapter = "gleba",
      objectives = {
        { type = "produce", item = "bioflux", count = 200 },
        { type = "produce", item = "agricultural-science-pack", count = 500 },
      } },
  },
})

---------------------------------------------------------------------------
-- Moshine, the data moon.
---------------------------------------------------------------------------

add_group({ "Moshine" }, {
  chapters = {
    { id = "moshine", icon = "space-location/moshine" },
  },
  quests = {
    { id = "moshine-arrival", chapter = "moshine", requires = { "vulcanus-science", "fulgora-science" },
      objectives = {
        { type = "research", tech = "planet-discovery-moshine" },
        { type = "visit", planet = "moshine" },
        -- K2SO converts sand and silicon into their kr- variants.
        { type = "produce", item = "sand", alternatives = { "kr-sand" }, count = 300 },
        { type = "produce", item = "silicon", alternatives = { "kr-silicon" }, count = 200 },
      } },
    { id = "moshine-data", chapter = "moshine", requires = { "moshine-arrival" },
      objectives = {
        { type = "research", tech = "moshine-tech-datacell-empty" },
        { type = "research", tech = "moshine-tech-data-processor-building" },
        { type = "research", tech = "moshine-tech-neural_computer" },
        { type = "build", entity = "data-processor", count = 2 },
        { type = "build", entity = "neural_computer", count = 1 },
      } },
    { id = "moshine-ai", chapter = "moshine", requires = { "moshine-data" },
      objectives = {
        { type = "research", tech = "moshine-tech-data-extractor" },
        { type = "research", tech = "moshine-tech-processing-grid" },
        { type = "research", tech = "moshine-tech-ai-trainer" },
        { type = "build", entity = "data-extractor", count = 2 },
        { type = "build", entity = "ai-trainer", count = 2 },
        { type = "produce", item = "model-stable", count = 25 },
      } },
    { id = "moshine-scanner", chapter = "moshine", requires = { "moshine-ai" },
      objectives = {
        { type = "research", tech = "moshine-tech-cosmicscanner-construction1" },
        { type = "research", tech = "moshine-tech-cosmicscanner-construction5" },
        { type = "build", entity = "moshine_cosmicscanner", count = 1 },
        { type = "produce", item = "datacell-cosmic-data", count = 1 },
      } },
  },
})

---------------------------------------------------------------------------
-- Maraxsis, the ocean world. Before Aquilo.
---------------------------------------------------------------------------

add_group({ "maraxsis" }, {
  chapters = {
    { id = "maraxsis", icon = "space-location/maraxsis" },
  },
  quests = {
    { id = "maraxsis-arrival", chapter = "maraxsis", requires = { "vulcanus-science", "fulgora-science", "gleba-science" },
      objectives = {
        { type = "research", tech = "planet-discovery-maraxsis" },
        { type = "visit", planet = "maraxsis" },
        { type = "research", tech = "maraxsis-glassworking" },
        { type = "research", tech = "maraxsis-hydro-plant" },
        { type = "build", entity = "maraxsis-hydro-plant", count = 1 },
      } },
    { id = "maraxsis-trench", chapter = "maraxsis", requires = { "maraxsis-arrival" },
      objectives = {
        { type = "research", tech = "maraxsis-piscary" },
        { type = "research", tech = "maraxsis-geothermal-energy" },
        { type = "build", entity = "maraxsis-trench-duct", count = 2 },
        { type = "build", entity = "maraxsis-geothermal-generator", count = 2 },
      } },
    { id = "maraxsis-science", chapter = "maraxsis", requires = { "maraxsis-trench" },
      objectives = {
        { type = "research", tech = "maraxsis-wyrm-confinement" },
        { type = "research", tech = "hydraulic-science-pack" },
        { type = "produce", item = "hydraulic-science-pack", count = 200 },
      } },
    { id = "maraxsis-seadragon", chapter = "maraxsis", requires = { "maraxsis-science" },
      objectives = {
        { type = "research", tech = "maraxsis-project-seadragon" },
        { type = "research", tech = "maraxsis-sonar" },
        { type = "build", entity = "maraxsis-sonar", count = 1 },
        { type = "build", entity = "maraxsis-nuclear-submarine", count = 1 },
      } },
  },
})

---------------------------------------------------------------------------
-- Space Age: the frozen planet.
---------------------------------------------------------------------------

add_group({ "space-age" }, {
  chapters = {
    { id = "aquilo", icon = "space-location/aquilo" },
  },
  quests = {
    -- Chapter: Aquilo
    -- gleba-science keeps the chapter gated when Maraxsis is not installed
    { id = "aquilo-landing", chapter = "aquilo", requires = { "gleba-science", "maraxsis-science" },
      objectives = {
        { type = "research", tech = "planet-discovery-aquilo" },
        { type = "visit", planet = "aquilo" },
        { type = "build", entity = "heating-tower", count = 1 },
      } },
    { id = "aquilo-science", chapter = "aquilo",
      objectives = {
        { type = "build", entity = "cryogenic-plant", count = 1 },
        { type = "produce", item = "lithium-plate", count = 200 },
        { type = "produce", item = "cryogenic-science-pack", count = 500 },
      } },
    { id = "fusion", chapter = "aquilo",
      objectives = {
        { type = "research", tech = "fusion-reactor" },
        { type = "build", entity = "fusion-reactor", count = 1 },
        { type = "build", entity = "fusion-generator", count = 2 },
      } },
  },
})

---------------------------------------------------------------------------
-- Krastorio 2: matter and singularity, after Aquilo and before the edge.
---------------------------------------------------------------------------

add_group({ "Krastorio2" }, {
  chapters = {
    { id = "k2-matter", icon = "item/kr-matter-tech-card" },
  },
  quests = {
    -- k2-imersium keeps the chapter gated when Space Age is not installed
    { id = "k2-matter", chapter = "k2-matter", requires = { "k2-imersium", "aquilo-science" },
      objectives = {
        { type = "research", tech = "kr-matter-tech-card" },
        { type = "produce", item = "kr-matter-tech-card", count = 150 },
        { type = "research", tech = "kr-singularity-tech-card" },
        { type = "build", entity = "kr-singularity-lab", count = 1 },
        { type = "produce", item = "kr-singularity-tech-card", count = 100 },
      } },
  },
})

---------------------------------------------------------------------------
-- Space Age: the edge of the solar system.
---------------------------------------------------------------------------

add_group({ "space-age" }, {
  chapters = {
    { id = "edge", icon = "space-location/solar-system-edge" },
  },
  quests = {
    -- Chapter: the edge
    { id = "railgun", chapter = "edge", requires = { "aquilo-science" },
      objectives = {
        { type = "research", tech = "railgun" },
        { type = "build", entity = "railgun-turret", count = 2 },
      } },
    { id = "edge", chapter = "edge",
      objectives = {
        { type = "reach", location = "solar-system-edge" },
      } },
    { id = "shattered", chapter = "edge",
      objectives = {
        { type = "research", tech = "promethium-science-pack" },
        { type = "produce", item = "promethium-science-pack", count = 1000 },
        { type = "reach", location = "shattered-planet" },
      } },
  },
})

---------------------------------------------------------------------------
-- Krastorio 2: end game. After promethium: the antimatter reactor and the
-- intergalactic transceiver.
---------------------------------------------------------------------------

add_group({ "Krastorio2" }, {
  chapters = {
    { id = "k2-endgame", icon = "item/kr-intergalactic-transceiver" },
  },
  quests = {
    { id = "k2-singularity", chapter = "k2-endgame", requires = { "k2-matter", "shattered" },
      objectives = {
        { type = "research", tech = "kr-antimatter-reactor" },
        { type = "build", entity = "kr-antimatter-reactor", count = 20 },
        { type = "research", tech = "kr-intergalactic-transceiver" },
        { type = "build", entity = "kr-intergalactic-transceiver", count = 1 },
      } },
  },
})

return { chapters = chapters, quests = quests, roman = to_roman }

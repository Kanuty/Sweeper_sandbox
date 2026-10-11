extends Node

# Indicator definitions for Post-Apocalyptic Hibernatus theme
# Standard indicators start at 50, game over if 0 or 100.
# Hazardous indicators start at 0, game over if max (100) is reached.
const INDICATORS = {
	0: {"name": "Energy", "icon_symbol": "⚡", "is_hazardous": false},
	1: {"name": "Food", "icon_symbol": "🥫", "is_hazardous": false},
	2: {"name": "Equipment", "icon_symbol": "🔧", "is_hazardous": false},
	3: {"name": "Sanity", "icon_symbol": "🧠", "is_hazardous": false},
	4: {"name": "Radiation", "icon_symbol": "☢️", "is_hazardous": true}
}

# Shop items list
var shop_items = [
	# Insights
	{
		"id": "item_exact_insight",
		"name": "Geiger-Counter Insight (Permanent)",
		"description": "Shows EXACT indicator value changes for every decision.",
		"price": 150,
		"type": "exact_insight",
		"charges": 0,
		"category": "insight"
	},
	{
		"id": "item_small_insight",
		"name": "Scout Recon Insight (Permanent)",
		"description": "Shows approximate value change ranges for every decision.",
		"price": 80,
		"type": "small_insight",
		"charges": 0,
		"category": "insight"
	},
	{
		"id": "item_timed_exact_insight",
		"name": "Calibrated Radar (3 Blocks)",
		"description": "Shows EXACT deltas for the next 3 Decision Blocks.",
		"price": 50,
		"type": "timed_exact_insight",
		"charges": 3,
		"category": "insight"
	},
	{
		"id": "item_timed_small_insight",
		"name": "Binoculars Scout (3 Blocks)",
		"description": "Shows value change ranges for the next 3 Decision Blocks.",
		"price": 30,
		"type": "timed_small_insight",
		"charges": 3,
		"category": "insight"
	},
	# Protections
	{
		"id": "prot_small_energy_min",
		"name": "Battery Pack (Energy Min Shield)",
		"description": "Prevents Game Over if Energy drops to 0. Takes 5 decisions to recharge.",
		"price": 60,
		"type": "protection",
		"prot_type": "small",
		"indicator": 0,
		"mode": "min",
		"cooldown_install": 5,
		"category": "protection"
	},
	{
		"id": "prot_small_rad_max",
		"name": "Rad-X Injector (Radiation Max Shield)",
		"description": "Prevents Game Over if Radiation reaches 100 max. Takes 5 decisions to recharge.",
		"price": 65,
		"type": "protection",
		"prot_type": "small",
		"indicator": 4,
		"mode": "max",
		"cooldown_install": 5,
		"category": "protection"
	},
	{
		"id": "prot_big_sanity",
		"name": "Neural Fortifier (Sanity Min & Max Shield)",
		"description": "Protects Sanity from BOTH 0 breakdown and 100 mania. Takes 7 decisions to recharge.",
		"price": 120,
		"type": "protection",
		"prot_type": "big",
		"indicator": 3,
		"mode": "both",
		"cooldown_install": 7,
		"category": "protection"
	},
	{
		"id": "prot_big_radiation",
		"name": "Lead Hazard Suit (Radiation Hazard Shield)",
		"description": "Absorbs lethal Radiation spikes before critical overload. Takes 7 decisions to recharge.",
		"price": 130,
		"type": "protection",
		"prot_type": "big",
		"indicator": 4,
		"mode": "max",
		"cooldown_install": 7,
		"category": "protection"
	},
	{
		"id": "prot_super_omni",
		"name": "Exo-Bunker Armor (Omni Shield)",
		"description": "Covers ALL indicators from high/low extreme collapses simultaneously.",
		"price": 500,
		"type": "protection",
		"prot_type": "super",
		"locked": true,
		"category": "protection"
	}
]

# Decision blocks categorized by world stage/theme
# Categories:
# "shelter": Waking up from hibernation, shelter maintenance, vault exit.
# "wilderness": Generic wasteland events (rad storms, mutants, ruins). Can repeat.
# "encounter": Special non-generic encounters (Trader convoy, Outpost, Ruined Village, Underground Lab).
# Focused deltas: Decisions affect 1-2 indicators primarily!
var decision_blocks = [
	# ---------------- SHELTER BLOCKS ----------------
	{
		"id": "shelter_01",
		"category": "shelter",
		"is_generic": false,
		"time_cost_hours": 12,
		"reward_points": 20,
		"story_cards": [
			{
				"title": "SLUMBER TERMINATED: Vault Cryo-Pod 09",
				"location": "Sub-Level 4 - Cryo Vault",
				"description": "Frost hisses away as your pod unseals. Emergency lights blink red. You have been in cryo-slumber for decades. Your body feels stiff and exhausted."
			},
			{
				"title": "DIAGNOSTIC WARNING: Life Support Failure",
				"location": "Shelter Control Hub",
				"description": "Power cells are failing and vault air filters are choked with ancient dust."
			}
		],
		"decision_card": {
			"title": "DECISION: Primary Shelter Restoration",
			"description": "How will you handle your waking exhaustion?",
			"choices": {
				"left": {
					"label": "Sleep Extra Hour in Cryo-Bay (Rest)",
					"deltas": [20, 0, 0, 0, 0],
					"affected": [0]
				},
				"right": {
					"label": "Force Main Vault Doors Open (Exertion)",
					"deltas": [-15, 0, 15, 0, 0],
					"affected": [0, 2]
				},
				"up": {
					"label": "Purge Rad-Air Filters First",
					"deltas": [0, 0, 0, 0, -20],
					"affected": [4]
				}
			}
		}
	},
	{
		"id": "shelter_02",
		"category": "shelter",
		"is_generic": false,
		"time_cost_hours": 18,
		"reward_points": 30,
		"story_cards": [
			{
				"title": "THE VAULT DOOR STEP: Leaving the Shelter",
				"location": "Shelter Airlock Gate",
				"description": "The heavy steel door creaks open. Unfamiliar sunlight blinds your eyes. A dry, radioactive wind sweeps across scorched ruins."
			}
		],
		"decision_card": {
			"title": "DECISION: First Footsteps into the Wasteland",
			"description": "What will you prioritize as you step out?",
			"choices": {
				"left": {
					"label": "Salvage Heavy Gear (Heavy Load)",
					"deltas": [-15, 0, 20, 0, 0],
					"affected": [0, 2]
				},
				"right": {
					"label": "Eat Vault Emergency Rations",
					"deltas": [10, 15, 0, 0, 0],
					"affected": [0, 1]
				},
				"up": {
					"label": "Pace Yourself Carefully",
					"deltas": [15, 0, 0, 10, 0],
					"affected": [0, 3]
				}
			}
		}
	},

	# ---------------- WILDERNESS BLOCKS (Generic / Repeatable) ----------------
	{
		"id": "wild_01",
		"category": "wilderness",
		"is_generic": true,
		"time_cost_hours": 24,
		"reward_points": 25,
		"story_cards": [
			{
				"title": "WASTELAND EVENT: Toxic Fallout Storm",
				"location": "The Scorched Flats",
				"description": "Dark green clouds gather on the horizon. The Geiger counter starts ticking violently as acidic rain begins to fall."
			}
		],
		"decision_card": {
			"title": "DECISION: Toxic Storm Shelter",
			"description": "How do you handle the radioactive fallout storm?",
			"choices": {
				"left": {
					"label": "Hunker Down and Sleep through Storm",
					"deltas": [15, -10, 0, 0, 0],
					"affected": [0, 1]
				},
				"right": {
					"label": "Sprint across Flats to Cave",
					"deltas": [-20, 0, 0, 0, 15],
					"affected": [0, 4]
				},
				"up": {
					"label": "Use Decontamination Scrubbers",
					"deltas": [0, 0, -10, 0, -25],
					"affected": [2, 4]
				}
			}
		}
	},
	{
		"id": "wild_02",
		"category": "wilderness",
		"is_generic": true,
		"time_cost_hours": 36,
		"reward_points": 35,
		"story_cards": [
			{
				"title": "WASTELAND EVENT: Ruined Supermarket Salvage",
				"location": "Overgrown Suburbs",
				"description": "A collapsed department store looms in the weeds. Broken glass and rusted shelves hold forgotten canned goods."
			}
		],
		"decision_card": {
			"title": "DECISION: Scavenging Strategy",
			"description": "Where will you focus your energy inside the collapse?",
			"choices": {
				"left": {
					"label": "Search Basements for Spare Parts",
					"deltas": [-10, 0, 20, 0, 0],
					"affected": [0, 2]
				},
				"right": {
					"label": "Ransack Food Aisle for Rations",
					"deltas": [0, 25, 0, 0, 0],
					"affected": [1]
				},
				"up": {
					"label": "Rest on Supermarket Couch",
					"deltas": [20, -5, 0, 10, 0],
					"affected": [0, 1, 3]
				}
			}
		}
	},
	{
		"id": "wild_03",
		"category": "wilderness",
		"is_generic": true,
		"time_cost_hours": 18,
		"reward_points": 20,
		"story_cards": [
			{
				"title": "WASTELAND EVENT: Mutated Pack Stalkers",
				"location": "Dead Woods Pass",
				"description": "Snarls echo through the ash trees. Glowing eyes reflect in the twilight—a pack of rad-mutated hounds surrounds your camp."
			}
		],
		"decision_card": {
			"title": "DECISION: Beast Ambush Response",
			"description": "How will you handle the ravenous beast pack?",
			"choices": {
				"left": {
					"label": "Adrenaline Sprint Away (Energy Strain)",
					"deltas": [-25, 0, 0, 0, 0],
					"affected": [0]
				},
				"right": {
					"label": "Stand & Fight with Scrap Rifle",
					"deltas": [0, 0, -15, 10, 0],
					"affected": [2, 3]
				},
				"up": {
					"label": "Toss Canned Rations to Distract",
					"deltas": [0, -20, 0, 10, 0],
					"affected": [1, 3]
				}
			}
		}
	},

	# ---------------- THEMATIC / SPECIAL ENCOUNTER BLOCKS ----------------
	{
		"id": "enc_outpost_01",
		"category": "encounter",
		"is_generic": false,
		"time_cost_hours": 48,
		"reward_points": 50,
		"story_cards": [
			{
				"title": "SPECIAL ENCOUNTER: Scrap Town Outpost",
				"location": "Sector 7 Outpost - Rust Citadel",
				"description": "A fortified settlement made of shipping containers rises above the dust. Guard turrets track your every move."
			}
		],
		"decision_card": {
			"title": "DECISION: Outpost Negotiations",
			"description": "How do you deal with the Rust Citadel outpost?",
			"choices": {
				"left": {
					"label": "Trade Tool Gear for Hot Meal",
					"deltas": [10, 20, -15, 0, 0],
					"affected": [0, 1, 2]
				},
				"right": {
					"label": "Work Heavy Repairs Shift",
					"deltas": [-20, 15, 15, 0, 0],
					"affected": [0, 1, 2]
				},
				"up": {
					"label": "Bribe Guards with Rations to Rest in Bed",
					"deltas": [25, -15, 0, 10, 0],
					"affected": [0, 1, 3]
				}
			}
		}
	},
	{
		"id": "enc_trader_01",
		"category": "encounter",
		"is_generic": false,
		"time_cost_hours": 30,
		"reward_points": 40,
		"story_cards": [
			{
				"title": "SPECIAL ENCOUNTER: Nomad Caravan",
				"location": "Old Highway 101",
				"description": "Armored dune buggies towing supply trailers pull up along the highway. A heavily armed trader offers bartering."
			}
		],
		"decision_card": {
			"title": "DECISION: Caravan Trade & Barter",
			"description": "Choose your bartering deal with the Nomads.",
			"choices": {
				"left": {
					"label": "Trade Spare Gear for Anti-Rad Meds",
					"deltas": [0, 0, -20, 0, -30],
					"affected": [2, 4]
				},
				"right": {
					"label": "Buy High-Capacity Energy Drinks",
					"deltas": [30, -10, 0, 0, 0],
					"affected": [0, 1]
				},
				"up": {
					"label": "Trade Rations for Stimulant Shots",
					"deltas": [25, -20, 0, 0, 0],
					"affected": [0, 1]
				}
			}
		}
	},
	{
		"id": "enc_lab_01",
		"category": "encounter",
		"is_generic": false,
		"time_cost_hours": 60,
		"reward_points": 75,
		"story_cards": [
			{
				"title": "SPECIAL ENCOUNTER: Subterranean Pre-War Lab",
				"location": "Bio-Tech Complex Bravo",
				"description": "An abandoned pre-war underground facility lies hidden beneath a crater. Leaking containment glowing violet."
			}
		],
		"decision_card": {
			"title": "DECISION: Pre-War Facility Raid",
			"description": "How deep into the reactor zone will you venture?",
			"choices": {
				"left": {
					"label": "Exertion Core Raid for Advanced Gear",
					"deltas": [-25, 0, 35, 0, 35],
					"affected": [0, 2, 4]
				},
				"right": {
					"label": "Cautious Perimeter Salvage",
					"deltas": [-10, 0, 15, 0, 10],
					"affected": [0, 2, 4]
				},
				"up": {
					"label": "Flush Core Rad-Scrubbers",
					"deltas": [0, 0, -10, 0, -35],
					"affected": [2, 4]
				}
			}
		}
	}
]

func get_block_by_id(block_id: String) -> Dictionary:
	for block in decision_blocks:
		if block["id"] == block_id:
			return block
	return decision_blocks[0]

# Block Selection / Sequence Logic:
# 1. First, play non-generic shelter blocks if not yet completed.
# 2. Then, choose from remaining non-generic thematic encounter blocks.
# 3. If all non-generic blocks are used (or for generic filler), pick from generic wilderness blocks.
func get_random_block(used_ids: Array = []) -> Dictionary:
	# Priority 1: Unused shelter blocks
	var unused_shelter = []
	for b in decision_blocks:
		if b.get("category", "") == "shelter" and not b.get("is_generic", false):
			if not b["id"] in used_ids:
				unused_shelter.append(b)
	if unused_shelter.size() > 0:
		return unused_shelter[0] # Sequential shelter awakening

	# Priority 2: Unused special encounter blocks
	var unused_encounters = []
	for b in decision_blocks:
		if b.get("category", "") == "encounter" and not b.get("is_generic", false):
			if not b["id"] in used_ids:
				unused_encounters.append(b)

	# 50% chance to run a special encounter if available, else generic wilderness
	if unused_encounters.size() > 0 and (randf() > 0.4 or used_ids.size() % 2 == 0):
		return unused_encounters[randi() % unused_encounters.size()]

	# Priority 3: Generic wilderness blocks (repeatable)
	var generic_blocks = []
	for b in decision_blocks:
		if b.get("is_generic", false):
			generic_blocks.append(b)

	if generic_blocks.size() > 0:
		return generic_blocks[randi() % generic_blocks.size()]

	# Fallback if needed
	return decision_blocks[randi() % decision_blocks.size()]

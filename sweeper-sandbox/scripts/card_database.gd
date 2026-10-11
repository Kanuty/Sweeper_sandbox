extends Node

# Indicator definitions for Post-Apocalyptic Hibernatus theme
# Standard indicators start at 50, game over if 0 or 100.
# Hazardous indicators start at 0, game over if max (100) is reached.
const INDICATORS = {
	0: {"name": "Energy", "icon_symbol": "⚡", "is_hazardous": false},
	1: {"name": "Trust", "icon_symbol": "🤝", "is_hazardous": false},
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
				"description": "Frost hisses away as your pod unseals. Emergency lights blink red. You have been in cryo-slumber for decades. The automated shelter AI glimmers."
			},
			{
				"title": "DIAGNOSTIC WARNING: Life Support Failure",
				"location": "Shelter Control Hub",
				"description": "Power cells are failing, filters are choked with ancient dust, and the vault seal is locked from the outside."
			}
		],
		"decision_card": {
			"title": "DECISION: Primary Shelter Restoration",
			"description": "How will you allocate remaining emergency reserves before exiting?",
			"choices": {
				"left": {
					"label": "Reroute Emergency Power to Life Support",
					"deltas": [15, 0, -10, 10, -5],
					"affected": [0, 2, 3, 4]
				},
				"right": {
					"label": "Overclock Tools to Force Main Vault Doors",
					"deltas": [-10, 0, 20, -5, 10],
					"affected": [0, 2, 3, 4]
				},
				"up": {
					"label": "Purge Rad-Air Filters First",
					"deltas": [-5, 0, -5, 15, -20],
					"affected": [0, 2, 3, 4]
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
				"description": "The heavy steel door creaks open with a deafening screech. Unfamiliar sunlight blinds your eyes. A dry, radioactive wind sweeps across scorched ruins."
			}
		],
		"decision_card": {
			"title": "DECISION: First Footsteps into the Wasteland",
			"description": "What will you take with you as you leave the shelter behind?",
			"choices": {
				"left": {
					"label": "Salvage Extra Scrap & Gear",
					"deltas": [-10, 0, 25, -10, 5],
					"affected": [0, 2, 3, 4]
				},
				"right": {
					"label": "Broadcast Friendly Signal to Near Frequencies",
					"deltas": [-5, 20, 0, 5, 0],
					"affected": [0, 1, 3]
				},
				"up": {
					"label": "Don Heavy Rad-Protection Gear",
					"deltas": [-15, 0, 10, 5, -25],
					"affected": [0, 2, 3, 4]
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
			"description": "How do you survive the radioactive fallout?",
			"choices": {
				"left": {
					"label": "Hunker Down under Reinforced Tarp",
					"deltas": [-15, 0, -5, -5, 10],
					"affected": [0, 2, 3, 4]
				},
				"right": {
					"label": "Sprint to Cave Ruin",
					"deltas": [-20, 0, 10, 5, -10],
					"affected": [0, 2, 3, 4]
				},
				"up": {
					"label": "Use Decontamination Scrubbers",
					"deltas": [-5, 0, -15, 10, -25],
					"affected": [0, 2, 3, 4]
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
				"description": "A collapsed department store looms in the weeds. Broken glass and rusted shelves hold forgotten canned goods and electronics."
			}
		],
		"decision_card": {
			"title": "DECISION: Scavenging Strategy",
			"description": "Where will you focus your search inside the collapse?",
			"choices": {
				"left": {
					"label": "Search Basements for Batteries & Tools",
					"deltas": [-10, 0, 20, 5, 15],
					"affected": [0, 2, 3, 4]
				},
				"right": {
					"label": "Ransack Food Aisle for Rations",
					"deltas": [20, 0, -5, 10, 0],
					"affected": [0, 2, 3]
				},
				"up": {
					"label": "Share Findings with Passing Wanders",
					"deltas": [-5, 25, -10, 10, 0],
					"affected": [0, 1, 2, 3]
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
					"label": "Fire Stun Flares & Flee",
					"deltas": [-15, 0, -5, 10, 0],
					"affected": [0, 2, 3]
				},
				"right": {
					"label": "Stand & Fight with Scrap Rifle",
					"deltas": [-10, 0, -15, -10, 10],
					"affected": [0, 2, 3, 4]
				},
				"up": {
					"label": "Toss Rations to Distract Them",
					"deltas": [-20, 10, 0, 10, 0],
					"affected": [0, 1, 3]
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
			},
			{
				"title": "MEETING THE CHIEF",
				"location": "Rust Citadel Council Hall",
				"description": "The town chief demands tribute or service in exchange for safe passage and trading rights."
			}
		],
		"decision_card": {
			"title": "DECISION: Outpost Negotiations",
			"description": "How do you align with the Rust Citadel survivors?",
			"choices": {
				"left": {
					"label": "Pay Tool & Energy Tribute",
					"deltas": [-15, 20, -15, 10, 0],
					"affected": [0, 1, 2, 3]
				},
				"right": {
					"label": "Offer Technical Repair Services",
					"deltas": [-20, 25, 10, 5, -5],
					"affected": [0, 1, 2, 3, 4]
				},
				"up": {
					"label": "Refuse Demands & Slip Away",
					"deltas": [-10, -20, 0, -10, 15],
					"affected": [0, 1, 3, 4]
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
				"description": "Armored dune buggies towing supply trailers pull up along the highway. A heavily armed trader offers a bartering opportunity."
			}
		],
		"decision_card": {
			"title": "DECISION: Caravan Trade & Barter",
			"description": "Choose your bartering deal with the Nomads.",
			"choices": {
				"left": {
					"label": "Trade Spare Gear for Anti-Rad Drugs",
					"deltas": [0, 10, -20, 5, -30],
					"affected": [1, 2, 3, 4]
				},
				"right": {
					"label": "Buy High-Capacity Battery Cells",
					"deltas": [30, 10, -15, 0, 0],
					"affected": [0, 1, 2]
				},
				"up": {
					"label": "Share Wasteland Maps & Recon",
					"deltas": [0, 30, -5, 15, 0],
					"affected": [1, 2, 3]
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
				"description": "An abandoned pre-war underground facility lies hidden beneath a crater. Automated security turrets hum faintly."
			},
			{
				"title": "HIGH HAZARD WARNING",
				"location": "Reactor Core Level",
				"description": "Deep inside, a leaking containment unit glows violet. High radiation, but pristine technological artifacts lie within."
			}
		],
		"decision_card": {
			"title": "DECISION: Pre-War Facility Raid",
			"description": "How deep into the reactor zone will you venture?",
			"choices": {
				"left": {
					"label": "Full Core Raid for Advanced Tech",
					"deltas": [-20, 0, 35, -15, 35],
					"affected": [0, 2, 3, 4]
				},
				"right": {
					"label": "Cautious Perimeter Salvage",
					"deltas": [-10, 0, 15, 5, 10],
					"affected": [0, 2, 3, 4]
				},
				"up": {
					"label": "Seal Core & Purge Radiation Spike",
					"deltas": [-15, 15, -10, 10, -30],
					"affected": [0, 1, 2, 3, 4]
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

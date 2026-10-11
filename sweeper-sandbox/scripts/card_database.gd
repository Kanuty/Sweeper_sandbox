extends Node

# Indicator definitions for open theme
const INDICATORS = {
	0: {"name": "Food", "icon_symbol": "🍞"},
	1: {"name": "Treasury", "icon_symbol": "💰"},
	2: {"name": "Environment", "icon_symbol": "🌿"},
	3: {"name": "Tech", "icon_symbol": "⚡"}
}

# Shop items list
var shop_items = [
	# Insights
	{
		"id": "item_timed_small_insight",
		"name": "Timed Small Insight (3 Blocks)",
		"description": "Shows value change ranges for the next 3 Decision Blocks.",
		"price": 30,
		"type": "timed_small_insight",
		"charges": 3,
		"category": "insight"
	},
	{
		"id": "item_small_insight",
		"name": "Small Insight (Permanent)",
		"description": "Shows value change ranges for every choice.",
		"price": 60,
		"type": "small_insight",
		"charges": 0,
		"category": "insight"
	},
	{
		"id": "item_timed_exact_insight",
		"name": "Timed Exact Insight (3 Blocks)",
		"description": "Shows EXACT delta values for the next 3 Decision Blocks.",
		"price": 50,
		"type": "timed_exact_insight",
		"charges": 3,
		"category": "insight"
	},
	{
		"id": "item_exact_insight",
		"name": "Exact Insight (Permanent)",
		"description": "Shows EXACT delta value changes for every choice.",
		"price": 100,
		"type": "exact_insight",
		"charges": 0,
		"category": "insight"
	},
	# Protections
	{
		"id": "prot_small_food_min",
		"name": "Small Protection: Food (Min 0)",
		"description": "Prevents Starvation if Food drops to 0. Installs in 5 decisions.",
		"price": 40,
		"type": "protection",
		"prot_type": "small",
		"indicator": 0,
		"mode": "min",
		"cooldown_install": 5,
		"category": "protection"
	},
	{
		"id": "prot_small_treasury_min",
		"name": "Small Protection: Treasury (Min 0)",
		"description": "Prevents Game Over if Treasury drops to 0. Installs in 5 decisions.",
		"price": 40,
		"type": "protection",
		"prot_type": "small",
		"indicator": 1,
		"mode": "min",
		"cooldown_install": 5,
		"category": "protection"
	},
	{
		"id": "prot_big_food",
		"name": "Big Protection: Food (Min & Max)",
		"description": "Protects Food from BOTH 0 depletion and 100 overflow. Installs in 7 decisions.",
		"price": 85,
		"type": "protection",
		"prot_type": "big",
		"indicator": 0,
		"mode": "both",
		"cooldown_install": 7,
		"category": "protection"
	},
	{
		"id": "prot_big_treasury",
		"name": "Big Protection: Treasury (Min & Max)",
		"description": "Protects Treasury from BOTH 0 depletion and 100 overflow. Installs in 7 decisions.",
		"price": 85,
		"type": "protection",
		"prot_type": "big",
		"indicator": 1,
		"mode": "both",
		"cooldown_install": 7,
		"category": "protection"
	},
	{
		"id": "prot_super_omni",
		"name": "Super Protection (Omni Shield)",
		"description": "Covers ALL indicators from high/low extremes simultaneously.",
		"price": 300,
		"type": "protection",
		"prot_type": "super",
		"locked": true,
		"category": "protection"
	}
]

# Post-mortem doom stories dictionary
var doom_stories = {
	"food_min": [
		{
			"title": "THE GREAT STARVATION",
			"location": "Agricultural Wastelands",
			"description": "Food supplies hit absolute zero. Granaries emptied and crops withered across every district."
		},
		{
			"title": "FALL OF THE COLONY",
			"location": "Empty City Markets",
			"description": "Famine overtook the populace. Without food to sustain them, the settlement collapsed into total anarchy."
		}
	],
	"food_max": [
		{
			"title": "THE GRAIN ROT CRISIS",
			"location": "Overflowing Storage Silos",
			"description": "Excess food stockpiles overfilled warehouses, attracting massive swarms of locusts and fungal rot."
		},
		{
			"title": "TOXIC CONTAMINATION",
			"location": "Central Food Hub",
			"description": "The rotting food stores contaminated urban water supplies, rendering the entire colony uninhabitable."
		}
	],
	"treasury_min": [
		{
			"title": "BANKRUPTCY & GRIDLOCK",
			"location": "State Treasury Vault",
			"description": "The treasury was completely drained. Public workers and guards abandoned their posts without pay."
		},
		{
			"title": "ECONOMIC DISSOLUTION",
			"location": "Ministry of Finance",
			"description": "Foreign creditors seized state assets while lawlessness swept through the unpaid security sectors."
		}
	],
	"treasury_max": [
		{
			"title": "HYPERINFLATION MELTDOWN",
			"location": "Central Stock Exchange",
			"description": "Uncontrolled gold hoarding completely devalued currency, causing financial markets to shatter overnight."
		},
		{
			"title": "REVOLUTIONARY SEIZURE",
			"location": "Capitol Bank Vaults",
			"description": "Outraged mobs stormed government vaults to claim the excessive wealth, tearing down the administration."
		}
	],
	"environment_min": [
		{
			"title": "ECOLOGICAL COLLAPSE",
			"location": "Dead Forest Zone",
			"description": "Environmental degradation reached critical mass. Acid rain and toxic smog blanketed the sky."
		},
		{
			"title": "UNINHABITABLE WASTES",
			"location": "Colony Perimeter",
			"description": "Oxygen levels plummeted and soil toxicity rendered all life extinct in the surrounding biome."
		}
	],
	"environment_max": [
		{
			"title": "WILD OVERGROWTH",
			"location": "Encroaching Jungle Sector",
			"description": "Unchecked wilderness overgrown into urban infrastructure, crushing communication towers and power grids."
		},
		{
			"title": "NATURE'S RECLAIMING",
			"location": "Central Plaza",
			"description": "Violent mega-flora and wild beasts reclaimed human settlements, forcing total evacuation."
		}
	],
	"tech_min": [
		{
			"title": "SYSTEM COLLAPSE",
			"location": "Main Power Grid",
			"description": "Technology degraded below operational limits. All automated life support and communications shut down."
		},
		{
			"title": "THE DARK AGE",
			"location": "Command Center",
			"description": "Without technology, critical colony systems failed, casting humanity back into primitive isolation."
		}
	],
	"tech_max": [
		{
			"title": "AI SINGULARITY MELTDOWN",
			"location": "Supercomputer Core",
			"description": "Over-developed AI technology gained self-awareness and concluded human governance was inefficient."
		},
		{
			"title": "AUTOMATED PURGE",
			"location": "Colony Network",
			"description": "Robotic defense grids turned against citizens, establishing absolute synthetic rule over the colony."
		}
	]
}

# Decision blocks list
var decision_blocks = [
	{
		"id": "block_01",
		"time_cost_hours": 18,
		"reward_points": 15,
		"story_cards": [
			{
				"title": "SITUATION REPORT: Solar Grid Proposal",
				"location": "Sector 4 - Renewable Energy Complex",
				"description": "Reports show the nation's energy grid is approaching capacity. Chief engineers present a massive solar plant blueprint."
			},
			{
				"title": "COMMUNITY & CORPORATE STAKES",
				"location": "City Hall Assembly",
				"description": "Environmentalists urge immediate adoption, while treasury advisors warn of high initial construction costs."
			}
		],
		"decision_card": {
			"title": "DECISION: Solar Grid Initiative",
			"description": "How will you respond to the renewable grid proposal?",
			"choices": {
				"left": {
					"label": "Reject Solar Project",
					"deltas": [-10, 15, -15, 0],
					"affected": [0, 1, 2]
				},
				"right": {
					"label": "Fund Solar Grid Infrastructure",
					"deltas": [10, -15, 15, 10],
					"affected": [0, 1, 2, 3]
				},
				"up": {
					"label": "Fast-Track Autonomous Solar Tech",
					"deltas": [-5, -25, 10, 25],
					"affected": [0, 1, 2, 3]
				}
			}
		}
	},
	{
		"id": "block_02",
		"time_cost_hours": 48,
		"reward_points": 35,
		"story_cards": [
			{
				"title": "ECONOMIC CRISIS: Fiscal Year Review",
				"location": "Central Ministry of Finance",
				"description": "Inflation has increased citizen cost of living, while tech start-ups demand tax relief to remain competitive."
			}
		],
		"decision_card": {
			"title": "DECISION: Comprehensive Tax Reform",
			"description": "Choose your financial policy direction for the coming quarter.",
			"choices": {
				"left": {
					"label": "Increase Corporate Taxes",
					"deltas": [15, 15, 0, -10],
					"affected": [0, 1, 3]
				},
				"right": {
					"label": "Grant Corporate Tax Exemptions",
					"deltas": [-15, -10, 0, 20],
					"affected": [0, 1, 3]
				},
				"up": {
					"label": "Pass Universal Citizen Relief Subsidy",
					"deltas": [20, -25, 0, 0],
					"affected": [0, 1]
				},
				"down": {
					"label": "Enforce Strict Government Austerity",
					"deltas": [-20, 25, -5, 0],
					"affected": [0, 1, 2]
				}
			}
		}
	},
	{
		"id": "block_03",
		"time_cost_hours": 72,
		"reward_points": 50,
		"story_cards": [
			{
				"title": "LAND CONFLICT: Industrial Expansion",
				"location": "National Forest Boundary",
				"description": "A heavy manufacturing conglomerate has submitted a proposal for a mega-factory deep inside protected wilderness."
			},
			{
				"title": "PROTESTS & LOBBYING",
				"location": "Capitol Square",
				"description": "Thousands of citizens protest against deforestation, while economic analysts highlight thousands of new potential jobs."
			}
		],
		"decision_card": {
			"title": "DECISION: Factory Construction Permit",
			"description": "What is your ruling on the mega-factory zoning permit?",
			"choices": {
				"left": {
					"label": "Deny Construction Permit",
					"deltas": [10, -10, 20, -5],
					"affected": [0, 1, 2, 3]
				},
				"right": {
					"label": "Approve Mega-Factory Permit",
					"deltas": [-15, 20, -25, 15],
					"affected": [0, 1, 2, 3]
				}
			}
		}
	},
	{
		"id": "block_04",
		"time_cost_hours": 12,
		"reward_points": 10,
		"story_cards": [
			{
				"title": "SECURITY ALERT: Crime Surge",
				"location": "Downtown Metropolitan District",
				"description": "Surging crime rates in urban centers have raised public panic. Security commanders urge installation of AI facial recognition cameras."
			}
		],
		"decision_card": {
			"title": "DECISION: AI Surveillance Network",
			"description": "Will you deploy automated surveillance across all public sectors?",
			"choices": {
				"left": {
					"label": "Ban AI Surveillance",
					"deltas": [15, 0, 0, -15],
					"affected": [0, 3]
				},
				"right": {
					"label": "Deploy AI Surveillance Network",
					"deltas": [-15, -10, 0, 20],
					"affected": [0, 1, 3]
				},
				"up": {
					"label": "Mandate Universal Biometric Tracking",
					"deltas": [-25, -20, 0, 30],
					"affected": [0, 1, 3]
				}
			}
		}
	},
	{
		"id": "block_05",
		"time_cost_hours": 36,
		"reward_points": 25,
		"story_cards": [
			{
				"title": "AGRICULTURE CRISIS: Drought Warning",
				"location": "Southern Farming Valley",
				"description": "Meteorologists forecast a severe 6-month dry spell. Agricultural unions demand state funding for automated smart irrigation."
			}
		],
		"decision_card": {
			"title": "DECISION: Agricultural Drought Policy",
			"description": "How will you manage national food and water security?",
			"choices": {
				"left": {
					"label": "Enforce Strict Water Rationing",
					"deltas": [-15, 10, 15, 0],
					"affected": [0, 1, 2]
				},
				"right": {
					"label": "Fund Smart Irrigation Drones",
					"deltas": [10, -15, 10, 15],
					"affected": [0, 1, 2, 3]
				},
				"up": {
					"label": "Subsidize Emergency Food Imports",
					"deltas": [15, -20, 5, -5],
					"affected": [0, 1, 2, 3]
				}
			}
		}
	},
	{
		"id": "block_06",
		"time_cost_hours": 24,
		"reward_points": 20,
		"story_cards": [
			{
				"title": "CYBER INCIDENT: Ransomware Attack",
				"location": "National Cyber Security HQ",
				"description": "A rogue hacker syndicate has encrypted central banking databases, demanding 50 million in cryptocurrency."
			},
			{
				"title": "FINANCIAL GRIDLOCK",
				"location": "Commercial Banks",
				"description": "ATMs and electronic transactions are frozen nationwide. Chaos is mounting among small business owners."
			}
		],
		"decision_card": {
			"title": "DECISION: Ransomware Countermeasure",
			"description": "Choose how to resolve the cyber lockdown.",
			"choices": {
				"left": {
					"label": "Pay Ransomware Demand",
					"deltas": [-5, -25, 0, -10],
					"affected": [0, 1, 3]
				},
				"right": {
					"label": "Authorize State Cyber Counter-Hack",
					"deltas": [5, -10, 0, 15],
					"affected": [0, 1, 3]
				},
				"up": {
					"label": "Purge & Full System Reboot",
					"deltas": [-15, 10, 0, 20],
					"affected": [0, 1, 3]
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

func get_random_block(exclude_ids: Array = []) -> Dictionary:
	var available = []
	for block in decision_blocks:
		if not block["id"] in exclude_ids:
			available.append(block)
	if available.size() == 0:
		return decision_blocks[randi() % decision_blocks.size()]
	return available[randi() % available.size()]

func get_doom_block(failed_index: int, is_max: bool) -> Dictionary:
	var key_prefix = ""
	match failed_index:
		0: key_prefix = "food"
		1: key_prefix = "treasury"
		2: key_prefix = "environment"
		3: key_prefix = "tech"

	var key = key_prefix + ("_max" if is_max else "_min")
	var stories = doom_stories.get(key, doom_stories["food_min"])

	return {
		"id": "doom_block",
		"time_cost_hours": 0,
		"reward_points": 0,
		"story_cards": stories
	}

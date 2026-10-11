extends Node

# Indicator definitions for open theme
const INDICATORS = {
	0: {"name": "People", "icon_symbol": "👥"},
	1: {"name": "Treasury", "icon_symbol": "💰"},
	2: {"name": "Environment", "icon_symbol": "🌿"},
	3: {"name": "Tech", "icon_symbol": "⚡"}
}

# Rebalanced Shop items list
var shop_items = [
	# Insights
	{
		"id": "item_timed_small_insight",
		"name": "Timed Small Insight (3 Blocks)",
		"description": "Shows value change ranges for the next 3 Decision Blocks.",
		"price": 30, # Achievable around ~12-15 days survival
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
		"id": "prot_small_people_min",
		"name": "Small Protection: People (Min 0)",
		"description": "Prevents Game Over if People drops to 0. Installs in 5 decisions.",
		"price": 40, # Achievable around ~15 days survival
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
		"id": "prot_big_people",
		"name": "Big Protection: People (Min & Max)",
		"description": "Protects People from BOTH 0 depletion and 100 overflow. Installs in 7 decisions.",
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

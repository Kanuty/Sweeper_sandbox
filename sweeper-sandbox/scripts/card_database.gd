extends Node

# Indicator definitions for open theme
const INDICATORS = {
	0: {"name": "People", "icon_symbol": "👥"},
	1: {"name": "Treasury", "icon_symbol": "💰"},
	2: {"name": "Environment", "icon_symbol": "🌿"},
	3: {"name": "Tech", "icon_symbol": "⚡"}
}

# Card database list
var cards = [
	{
		"id": "card_01",
		"title": "Clean Energy Initiative",
		"description": "Engineers propose building a solar plant. It requires funding and land, but reduces pollution.",
		"choices": {
			"left": {
				"label": "Reject Project",
				"deltas": [-5, 10, -15, 0],
				"affected": [0, 1, 2] # People, Treasury, Environment
			},
			"right": {
				"label": "Fund Solar Grid",
				"deltas": [10, -15, 15, 10],
				"affected": [0, 1, 2, 3]
			},
			"up": {
				"label": "Over-invest Tech",
				"deltas": [-10, -25, 10, 25],
				"affected": [0, 1, 2, 3]
			},
			"down": {
				"label": "Delay Decision",
				"deltas": [-5, 0, -5, 0],
				"affected": [0, 2]
			}
		}
	},
	{
		"id": "card_02",
		"title": "Tax Reform",
		"description": "Citizens complain about rising costs, while corporations request tax exemptions for innovation.",
		"choices": {
			"left": {
				"label": "Tax Corporations",
				"deltas": [15, 15, 0, -10],
				"affected": [0, 1, 3]
			},
			"right": {
				"label": "Cut Citizen Tax",
				"deltas": [20, -20, 0, 5],
				"affected": [0, 1, 3]
			},
			"up": {
				"label": "Universal Subsidy",
				"deltas": [25, -30, 0, 0],
				"affected": [0, 1]
			},
			"down": {
				"label": "Austerity Measures",
				"deltas": [-20, 25, -5, 0],
				"affected": [0, 1, 2]
			}
		}
	},
	{
		"id": "card_03",
		"title": "Industrial Expansion",
		"description": "A major corporation wants to build a mega-factory in the national park area.",
		"choices": {
			"left": {
				"label": "Deny Permit",
				"deltas": [10, -10, 20, -5],
				"affected": [0, 1, 2, 3]
			},
			"right": {
				"label": "Approve Factory",
				"deltas": [-15, 20, -25, 15],
				"affected": [0, 1, 2, 3]
			},
			"up": {
				"label": "Automated Eco-Hub",
				"deltas": [0, -15, -5, 20],
				"affected": [1, 2, 3]
			},
			"down": {
				"label": "Protest Stoppage",
				"deltas": [-10, 0, 10, 0],
				"affected": [0, 2]
			}
		}
	},
	{
		"id": "card_04",
		"title": "AI Surveillance",
		"description": "Security forces urge installation of citywide AI surveillance to cut down crime rates.",
		"choices": {
			"left": {
				"label": "Ban Surveillance",
				"deltas": [15, 0, 0, -15],
				"affected": [0, 3]
			},
			"right": {
				"label": "Deploy AI System",
				"deltas": [-15, -10, 0, 20],
				"affected": [0, 1, 3]
			},
			"up": {
				"label": "Full Automation",
				"deltas": [-25, -20, 0, 30],
				"affected": [0, 1, 3]
			},
			"down": {
				"label": "Public Hearing",
				"deltas": [5, -5, 0, 0],
				"affected": [0, 1]
			}
		}
	},
	{
		"id": "card_05",
		"title": "Agricultural Modernization",
		"description": "Farmers demand new automated irrigation tech due to drought warnings.",
		"choices": {
			"left": {
				"label": "Traditional Farming",
				"deltas": [-10, 5, -10, -5],
				"affected": [0, 1, 2, 3]
			},
			"right": {
				"label": "Fund Smart Drones",
				"deltas": [10, -15, 10, 15],
				"affected": [0, 1, 2, 3]
			},
			"up": {
				"label": "Import Food Supplies",
				"deltas": [15, -20, 5, -5],
				"affected": [0, 1, 2, 3]
			},
			"down": {
				"label": "Water Rationing",
				"deltas": [-15, 10, 15, 0],
				"affected": [0, 1, 2]
			}
		}
	},
	{
		"id": "card_06",
		"title": "Cyber Security Breach",
		"description": "A rogue hacker group locked central financial databases demanding ransom.",
		"choices": {
			"left": {
				"label": "Pay Ransom",
				"deltas": [-5, -25, 0, -10],
				"affected": [0, 1, 3]
			},
			"right": {
				"label": "Counter-Hack",
				"deltas": [5, -10, 0, 15],
				"affected": [0, 1, 3]
			},
			"up": {
				"label": "Full System Reboot",
				"deltas": [-15, 10, 0, 20],
				"affected": [0, 1, 3]
			},
			"down": {
				"label": "Ignore Threat",
				"deltas": [-20, -20, 0, -20],
				"affected": [0, 1, 3]
			}
		}
	},
	{
		"id": "card_07",
		"title": "Public Health Emergency",
		"description": "A mysterious strain of flu spreads across major urban residential sectors.",
		"choices": {
			"left": {
				"label": "City Lockdown",
				"deltas": [-15, -15, 10, 0],
				"affected": [0, 1, 2]
			},
			"right": {
				"label": "Fast-Track Vaccine",
				"deltas": [15, -20, 0, 15],
				"affected": [0, 1, 3]
			},
			"up": {
				"label": "Nanotech Cure",
				"deltas": [20, -25, -5, 25],
				"affected": [0, 1, 2, 3]
			},
			"down": {
				"label": "Sanitation Blitz",
				"deltas": [5, -10, 15, 0],
				"affected": [0, 1, 2]
			}
		}
	},
	{
		"id": "card_08",
		"title": "Space Exploration Program",
		"description": "Scientists propose a orbital satellite grid for global climate and resource tracking.",
		"choices": {
			"left": {
				"label": "Scrap Program",
				"deltas": [-5, 15, -10, -15],
				"affected": [0, 1, 2, 3]
			},
			"right": {
				"label": "Launch Satellites",
				"deltas": [10, -20, 15, 20],
				"affected": [0, 1, 2, 3]
			},
			"up": {
				"label": "Deep Space Probe",
				"deltas": [15, -30, 0, 30],
				"affected": [0, 1, 3]
			},
			"down": {
				"label": "Ground Telescopes",
				"deltas": [5, -5, 0, 10],
				"affected": [0, 1, 3]
			}
		}
	}
]

func get_card_by_id(card_id: String) -> Dictionary:
	for card in cards:
		if card["id"] == card_id:
			return card
	return cards[0]

func get_random_card(exclude_ids: Array = []) -> Dictionary:
	var available = []
	for card in cards:
		if not card["id"] in exclude_ids:
			available.append(card)
	if available.size() == 0:
		# Reset pool if all used
		return cards[randi() % cards.size()]
	return available[randi() % available.size()]

RegularSizedSpeedrun = RegularSizedSpeedrun or { }
local RegularSizedSpeedrun = RegularSizedSpeedrun

ZoneID = {
	DSA =  635,
	HRC =  636,
	AA  =  638,
	SO  =  639,
	MA  =  677,
	MOL =  725,
	HOF =  975,
	AS  = 1000,
	CR  = 1051,
	BRP = 1082,
	SS  = 1121,
	KA  = 1196,
	VH  = 1227,
	RG  = 1263,
	DSR = 1344,
	SE  = 1427,
	LC  = 1478
}

RegularSizedSpeedrun.Data = {
	-------------------
	---- Raid List ----
	-------------------
	raidList = {
	    [ZoneID.HRC] = {
	        name = "HRC",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
	    [ZoneID.AA] = {
	        name = "AA",
	        timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
	    [ZoneID.SO] = {
	        name = "SO",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
	    [ZoneID.MOL] = {
	        name = "MoL",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
	    [ZoneID.HOF] = {
	        name = "HoF",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
	    [ZoneID.AS] = {
	        name = "AS",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
	    [ZoneID.CR] = {
	        name = "CR",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
	    [ZoneID.SS] = {
	        name = "SS",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
	    [ZoneID.KA] = {
	        name = "KA",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
		[ZoneID.RG] = {
	        name = "RG",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
		[ZoneID.DSR] = {
	        name = "DSR",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
		[ZoneID.SE] = {
	        name = "SE",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
		[ZoneID.LC] = {
	        name = "LC",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
	    [ZoneID.BRP] = {
	        name = "BRP",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
	    [ZoneID.DSA] = {
	        name = "DSA",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
	    },
		[ZoneID.MA] = {
			name = "MA",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
		},
		[ZoneID.VH] = {
			name = "VH",
			timerSteps = {},
			scoreFactors = {
				vitality = 0,
				bestTime = nil,
				bestScore = 0,
				scoreReasons = {},
			},
		},
	},

	-----------------------
	---- Custom Timers ----
	-----------------------
	customTimerSteps = {
	    [ZoneID.AA] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = "",
	        [7] = "",
	        [8] = ""
	    },
	    [ZoneID.HRC] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = ""
	    },
	    [ZoneID.SO] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = "",
	        [7] = "",
	        [8] = ""
	    },
	    [ZoneID.MOL] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = ""
	    },
	    [ZoneID.HOF] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = "",
	        [7] = "",
	        [8] = "",
	        [9] = "",
	        [10] = ""
	    },
	    [ZoneID.AS] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = ""
	    },
	    [ZoneID.CR] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = ""
	    },
	    [ZoneID.SS] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = ""
	    },
	    [ZoneID.KA] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = ""
	    },
		[ZoneID.RG] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = ""
	    },
		[ZoneID.DSR] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = ""
	    },
		[ZoneID.SE] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = ""
	    },
		[ZoneID.LC] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = ""
	    },
	    [ZoneID.BRP] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = "",
			[7] = "",
	        [8] = "",
	        [9] = "",
	        [10] = "",
	        [11] = "",
	        [12] = "",
			[13] = "",
	        [14] = "",
	        [15] = "",
	        [16] = "",
	        [17] = "",
	        [18] = "",
			[19] = "",
	        [20] = "",
	        [21] = "",
	        [22] = "",
	        [23] = "",
	        [24] = "",
			[25] = ""
	    },
	    [ZoneID.MA] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = "",
	        [7] = "",
	        [8] = "",
	        [9] = ""
	    },
	    [ZoneID.DSA] = {
	        [1] = "",
	        [2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = "",
	        [7] = "",
	        [8] = "",
	        [9] = "",
	        [10] = ""
	    },
		[ZoneID.VH] = { --Vateshran Hollows
			[1] = "",
	    	[2] = "",
	        [3] = "",
	        [4] = "",
	        [5] = "",
	        [6] = "",
	        [7] = ""
	    },
	},

	-------------------
	---- Step List ----
	-------------------
	stepList = {
	    [ZoneID.AA] = {
	        [1] = zo_strformat(SI_SPEEDRUN_AA_BEGIN_LIGHTNING),
	        [2] = zo_strformat(SI_SPEEDRUN_AA_FINISH_LIGHTNING),
	        [3] = zo_strformat(SI_SPEEDRUN_AA_BEGIN_STONE),
	        [4] = zo_strformat(SI_SPEEDRUN_AA_FINISH_STONE),
	        [5] = zo_strformat(SI_SPEEDRUN_AA_BEGIN_VARLARIEL),
	        [6] = zo_strformat(SI_SPEEDRUN_AA_FINISH_VARLARIEL),
	        [7] = zo_strformat(SI_SPEEDRUN_AA_BEGIN_MAGE),
	        [8] = zo_strformat(SI_SPEEDRUN_AA_FINISH_MAGE),
	    },
	    [ZoneID.HRC] = {
	        [1] = zo_strformat(SI_SPEEDRUN_HRC_BEGIN_RAKOTU),
	        [2] = zo_strformat(SI_SPEEDRUN_HRC_FINISH_RAKOTU),
	        [3] = zo_strformat(SI_SPEEDRUN_HRC_BEGIN_SECOND),
	        [4] = zo_strformat(SI_SPEEDRUN_HRC_FINISH_SECOND),
	        [5] = zo_strformat(SI_SPEEDRUN_HRC_BEGIN_WARRIOR),
	        [6] = zo_strformat(SI_SPEEDRUN_HRC_FINISH_WARRIOR),
	    },
	    [ZoneID.SO] = {
	        [1] = zo_strformat(SI_SPEEDRUN_SO_BEGIN_MANTIKORA),
	        [2] = zo_strformat(SI_SPEEDRUN_SO_FINISH_MANTIKORA),
	        [3] = zo_strformat(SI_SPEEDRUN_SO_BEGIN_TROLL),
	        [4] = zo_strformat(SI_SPEEDRUN_SO_FINISH_TROLL),
	        [5] = zo_strformat(SI_SPEEDRUN_SO_BEGIN_OZARA),
	        [6] = zo_strformat(SI_SPEEDRUN_SO_FINISH_OZARA),
	        [7] = zo_strformat(SI_SPEEDRUN_SO_BEGIN_SERPENT),
	        [8] = zo_strformat(SI_SPEEDRUN_SO_FINISH_SERPENT),
	    },
	    [ZoneID.MOL] = {
	        [1] = zo_strformat(SI_SPEEDRUN_MOL_BEGIN_ZHAJ),
	        [2] = zo_strformat(SI_SPEEDRUN_MOL_FINISH_ZHAJ),
	        [3] = zo_strformat(SI_SPEEDRUN_MOL_BEGIN_TWINS),
	        [4] = zo_strformat(SI_SPEEDRUN_MOL_FINISH_TWINS),
	        [5] = zo_strformat(SI_SPEEDRUN_MOL_BEGIN_RAKKHAT),
	        [6] = zo_strformat(SI_SPEEDRUN_MOL_FINISH_RAKKHAT),
	    },
	    [ZoneID.HOF] = {
	        [1] = zo_strformat(SI_SPEEDRUN_HOF_BEGIN_DYNO),
	        [2] = zo_strformat(SI_SPEEDRUN_HOF_FINISH_DYNO),
	        [3] = zo_strformat(SI_SPEEDRUN_HOF_BEGIN_FACTOTUM),
	        [4] = zo_strformat(SI_SPEEDRUN_HOF_FINISH_FACTOTUM),
	        [5] = zo_strformat(SI_SPEEDRUN_HOF_BEGIN_SPIDER),
	        [6] = zo_strformat(SI_SPEEDRUN_HOF_FINISH_SPIDER),
	        [7] = zo_strformat(SI_SPEEDRUN_HOF_BEGIN_COMMITEE),
	        [8] = zo_strformat(SI_SPEEDRUN_HOF_FINISH_COMMITEE),
	        [9] = zo_strformat(SI_SPEEDRUN_HOF_BEGIN_ASSEMBLY),
	        [10] = zo_strformat(SI_SPEEDRUN_HOF_FINISH_ASSEMBLY),
	    },
	    [ZoneID.AS] = {
	        [1] = zo_strformat(SI_SPEEDRUN_AS_BEGIN_OLMS),
	        [2] = zo_strformat(SI_SPEEDRUN_AS_90_PERCENT),
	        [3] = zo_strformat(SI_SPEEDRUN_AS_75_PERCENT),
	        [4] = zo_strformat(SI_SPEEDRUN_AS_50_PERCENT),
	        [5] = zo_strformat(SI_SPEEDRUN_AS_25_PERCENT),
	        [6] = zo_strformat(SI_SPEEDRUN_AS_KILL_OLMS),
	    },
	    [ZoneID.CR] = {
	        [1] = zo_strformat(SI_SPEEDRUN_CR_BEGIN_ZMAJA),
	        [2] = zo_strformat(SI_SPEEDRUN_CR_SIRORIA_APPEAR),
	        [3] = zo_strformat(SI_SPEEDRUN_CR_RELEQUEN_APPEAR),
	        [4] = zo_strformat(SI_SPEEDRUN_CR_GALENWE_APPEAR),
	        [5] = zo_strformat(SI_SPEEDRUN_CR_SHADOW_APPEAR),
	        [6] = zo_strformat(SI_SPEEDRUN_CR_KILL_SHADOW),
	    },
	    [ZoneID.SS] = {
	        [1] = zo_strformat(SI_SPEEDRUN_SS_BEGIN_FIRST),
	        [2] = zo_strformat(SI_SPEEDRUN_SS_KILL_FIRST),
	        [3] = zo_strformat(SI_SPEEDRUN_SS_BEGIN_SECOND),
	        [4] = zo_strformat(SI_SPEEDRUN_SS_KILL_SECOND),
	        [5] = zo_strformat(SI_SPEEDRUN_SS_BEGIN_LAST),
	        [6] = zo_strformat(SI_SPEEDRUN_SS_KILL_LAST),
	    },
	    [ZoneID.KA] = {
	        [1] = zo_strformat(SI_SPEEDRUN_KA_BEGIN_YANDIR),
	        [2] = zo_strformat(SI_SPEEDRUN_KA_KILL_YANDIR),
	        [3] = zo_strformat(SI_SPEEDRUN_KA_BEGIN_VROL),
	        [4] = zo_strformat(SI_SPEEDRUN_KA_KILL_VROL),
	        [5] = zo_strformat(SI_SPEEDRUN_KA_BEGIN_FALGRAVN),
	        [6] = zo_strformat(SI_SPEEDRUN_KA_KILL_FALGRAVN),
	    },
		[ZoneID.RG] = {
	        [1] = zo_strformat(SI_SPEEDRUN_RG_BEGIN_OAX),
	        [2] = zo_strformat(SI_SPEEDRUN_RG_KILL_OAX),
	        [3] = zo_strformat(SI_SPEEDRUN_RG_BEGIN_BAHSEI),
	        [4] = zo_strformat(SI_SPEEDRUN_RG_KILL_BAHSEI),
	        [5] = zo_strformat(SI_SPEEDRUN_RG_BEGIN_XAL),
	        [6] = zo_strformat(SI_SPEEDRUN_RG_KILL_XAL),
	    },
		[ZoneID.DSR] = {
	        [1] = zo_strformat(SI_SPEEDRUN_DSR_BEGIN_TWINS),
	        [2] = zo_strformat(SI_SPEEDRUN_DSR_KILL_TWINS),
	        [3] = zo_strformat(SI_SPEEDRUN_DSR_BEGIN_REEF),
	        [4] = zo_strformat(SI_SPEEDRUN_DSR_KILL_REEF),
	        [5] = zo_strformat(SI_SPEEDRUN_DSR_BEGIN_TALERIA),
	        [6] = zo_strformat(SI_SPEEDRUN_DSR_KILL_TALERIA),
	    },
		[ZoneID.SE] = {
	        [1] = zo_strformat(SI_SPEEDRUN_SE_BEGIN_YASEYLA),
	        [2] = zo_strformat(SI_SPEEDRUN_SE_KILL_YASEYLA),
	        [3] = zo_strformat(SI_SPEEDRUN_SE_BEGIN_CHIMERA),
	        [4] = zo_strformat(SI_SPEEDRUN_SE_KILL_CHIMERA),
	        [5] = zo_strformat(SI_SPEEDRUN_SE_BEGIN_ANSUUL),
	        [6] = zo_strformat(SI_SPEEDRUN_SE_KILL_ANSUUL),
	    },
		[ZoneID.LC] = {
	        [1] = zo_strformat(SI_SPEEDRUN_LC_BEGIN_COUNT),
	        [2] = zo_strformat(SI_SPEEDRUN_LC_KILL_COUNT),
	        [3] = zo_strformat(SI_SPEEDRUN_LC_BEGIN_ORPHIC),
	        [4] = zo_strformat(SI_SPEEDRUN_LC_KILL_ORPHIC),
	        [5] = zo_strformat(SI_SPEEDRUN_LC_BEGIN_XORYN),
	        [6] = zo_strformat(SI_SPEEDRUN_LC_KILL_XORYN),
	    },

	    [ZoneID.BRP] = {
	        [1] = "1.1",
	        [2] = "1.2",
	        [3] = "1.3",
	        [4] = "1.4",
	        [5] = "1st Complete",
	        [6] = "2.1",
					[7] = "2.2",
	        [8] = "2.3",
	        [9] = "2.4",
	        [10] = "2nd Complete",
	        [11] = "3.1",
	        [12] = "3.2",
					[13] = "3.3",
	        [14] = "3.4",
	        [15] = "3rd Complete",
	        [16] = "4.1",
	        [17] = "4.2",
	        [18] = "4.3",
					[19] = "4.4",
	        [20] = "4th Complete",
	        [21] = "5.1",
	        [22] = "5.2",
	        [23] = "5.3",
	        [24] = "5.4",
					[25] = "5th Complete",
	    },
	    [ZoneID.MA] = {
	        [1] = zo_strformat(SI_SPEEDRUN_ARENA_FIRST),
	        [2] = zo_strformat(SI_SPEEDRUN_ARENA_SECOND),
	        [3] = zo_strformat(SI_SPEEDRUN_ARENA_THIRD),
	        [4] = zo_strformat(SI_SPEEDRUN_ARENA_FOURTH),
	        [5] = zo_strformat(SI_SPEEDRUN_ARENA_FIFTH),
	        [6] = zo_strformat(SI_SPEEDRUN_ARENA_SIXTH),
	        [7] = zo_strformat(SI_SPEEDRUN_ARENA_SEVENTH),
	        [8] = zo_strformat(SI_SPEEDRUN_ARENA_EIGHTH),
			[9] = zo_strformat(SI_SPEEDRUN_ARENA_NINTH),	--zo_strformat(SI_SPEEDRUN_ARENA_COMPLETE),
	    },
	    [ZoneID.DSA] = {
	        [1] = zo_strformat(SI_SPEEDRUN_ARENA_FIRST),
	        [2] = zo_strformat(SI_SPEEDRUN_ARENA_SECOND),
	        [3] = zo_strformat(SI_SPEEDRUN_ARENA_THIRD),
	        [4] = zo_strformat(SI_SPEEDRUN_ARENA_FOURTH),
	        [5] = zo_strformat(SI_SPEEDRUN_ARENA_FIFTH),
	        [6] = zo_strformat(SI_SPEEDRUN_ARENA_SIXTH),
	        [7] = zo_strformat(SI_SPEEDRUN_ARENA_SEVENTH),
	        [8] = zo_strformat(SI_SPEEDRUN_ARENA_EIGHTH),
	        [9] = zo_strformat(SI_SPEEDRUN_ARENA_NINTH),
	        [10] = zo_strformat(SI_SPEEDRUN_ARENA_TENTH),
					-- [11] = zo_strformat(SI_SPEEDRUN_ARENA_COMPLETE),
	    },
		[ZoneID.VH] = {
	        [1] = "Boss 1",
	        [2] = "Boss 2",
	        [3] = "Boss 3",
	        [4] = "Boss 4",
	        [5] = "Boss 5",
	        [6] = "Boss 6",
			[7] = "Maebroogha |t20:20:esoui\\art\\icons\\poi\\poi_groupboss_incomplete.dds|t",
		},
	},
	--------------------
	---- Score List ----
	--------------------
	scoreReasonList = {
		[0] = {
				name = "No Bonus",
				id = RAID_POINT_REASON_MIN_VALUE,
				times = 0,
				total = 0
		},
		[1] = {
				name = "Small adds:",
				id = RAID_POINT_REASON_KILL_NORMAL_MONSTER,
				times = 0,
				total = 0
		},
		[2] = {
				name = "Large adds:",
				id = RAID_POINT_REASON_KILL_BANNERMEN,
				times = 0,
				total = 0
		},
		[3] = {
				name = "Elite adds:",
				id = RAID_POINT_REASON_KILL_CHAMPION,
				times = 0,
				total = 0
		},
		[4] = {
				name = "Miniboss",
				id = RAID_POINT_REASON_KILL_MINIBOSS,
				times = 0,
				total = 0
		},
		[5] = {
				name = "Boss",
				id = RAID_POINT_REASON_KILL_BOSS,
				times = 0,
				total = 0
		},
		[6] = {
				name = "Bonus Low (increased difficulty)",
				id = RAID_POINT_REASON_BONUS_ACTIVITY_LOW,
				times = 0,
				total = 0
		},
		[7] = {
				name = "Bonus Medium (increased difficulty)",
				id = RAID_POINT_REASON_BONUS_ACTIVITY_MEDIUM,
				times = 0,
				total = 0
		},
		[8] = {
				name = "Bonus High (HM)",
				id = RAID_POINT_REASON_BONUS_ACTIVITY_HIGH,
				times = 0,
				total = 0
		},
		[9] = {
				name = "Revives & Resurrections",
				id = RAID_POINT_REASON_LIFE_REMAINING,
				times = 0,
				total = 0
		},
		[10] = {
				name = "Bonus Point One",
				id = RAID_POINT_REASON_BONUS_POINT_ONE,
				times = 0,
				total = 0
		},
		[11] = {
				name = "Bonus Point Two",
				id = RAID_POINT_REASON_BONUS_POINT_TWO,
				times = 0,
				total = 0
		},
		[12] = {
				name = "Bonus Point Three",
				id = RAID_POINT_REASON_BONUS_POINT_THREE,
				times = 0,
				total = 0
		},
		[13] = {
				name = "Remaining Sigils Bonus x1",
				id = RAID_POINT_REASON_SOLO_ARENA_PICKUP_ONE,
				times = 0,
				total = 0
		},
		[14] = {
				name = "Remaining Sigils Bonus x2",
				id = RAID_POINT_REASON_SOLO_ARENA_PICKUP_TWO,
				times = 0,
				total = 0
		},
		[15] = {
				name = "Remaining Sigils Bonus x3",
				id = RAID_POINT_REASON_SOLO_ARENA_PICKUP_THREE,
				times = 0,
				total = 0
		},
		[16] = {
				name = "Remaining Sigils Bonus x4",
				id = RAID_POINT_REASON_SOLO_ARENA_PICKUP_FOUR,
				times = 0,
				total = 0
		},
		[17] = {
				name = "Completion Bonus (Stage / Trial)",
				id = RAID_POINT_REASON_MAX_VALUE,
				times = 0,
				total = 0
		}
	},
}
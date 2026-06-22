--!strict

export type ThemeColour = "background" | "primary" | "secondary" | "overlay"

export type AnimatedIcon = {
	fallbackUrls: {[ThemeColour]: string},
	duration: number,
	layers: {Layer}
}

export type Layer = {
	imageUrl: string,
	colour: ThemeColour,
	restTransform: Transform,
	motion: Motion?
}

export type Transform = {
	centre: Vector2,
	size: Vector2,
	angle: number
}

export type Motion = {
	type: "simple",
	goalTransform: Transform,
	action: "meet" | "boomerang" | "shake"
}

local TAU = math.pi * 2

local IMAGES = {
	circle = "",
	rightTriangle = "",
	square = "",
	lineDiagonal14 = "",
	arrowDiagonal8 = "",
	cube8 = "",
	corner = "",
	windowMid = "",
	square12Round2Dot5 = "",
	private = {
		sun = {
			sun = ""
		},
		cursor = {
			cursor = ""
		},
		arrowBounceHorizontal = {
			floorAndIncoming = ""
		},
	}
}

local function AnimatedIcon(x: AnimatedIcon)
	return x
end

local function Layer(x: Layer)
	return x
end

local function Transform(x: Transform)
	return x
end

local function Motion(x: Motion)
	return x
end

return {
	sun = AnimatedIcon {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = IMAGES.private.sun.sun,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(-0.5, -0.5) / 16,
					size = Vector2.new(15, 15) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-0.5, -0.5) / 16,
						size = Vector2.new(15, 15) / 16,
						angle = TAU / -2
					},
					action = "meet"
				}
			}
		}
	},

	moon = AnimatedIcon {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.zero,
					size = Vector2.new(14, 14) / 16,
					angle = 0
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(4, -4) / 16,
					size = Vector2.new(14, 14) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(4 - 24, -4 + 24) / 16,
						size = Vector2.new(24, 24) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(4 + 20, -4 - 20) / 16,
					size = Vector2.new(24, 24) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(4, -4) / 16,
						size = Vector2.new(14, 14) / 16,
						angle = 0
					},
					action = "meet"
				}
			}
		}
	},

	cursor = AnimatedIcon {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.6,
		layers = {
			Layer {
				imageUrl = IMAGES.private.cursor.cursor,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.zero,
					size = Vector2.new(10, 14) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-2.5, -4) / 16,
						size = Vector2.new(10, 14) / 16 * 0.5,
						angle = 0
					},
					action = "boomerang"
				}
			},
		}
	},

	arrowPerpendicular = AnimatedIcon {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.6,
		layers = {
			Layer {
				imageUrl = IMAGES.arrowDiagonal8,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(2, -2) / 16,
					size = Vector2.new(8, 8) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(2 - 4, -2 + 4) / 16,
						size = Vector2.new(8, 8) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = IMAGES.rightTriangle,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(-1, 1) / 16,
					size = Vector2.one,
					angle = 0
				}
			},
			Layer {
				imageUrl = IMAGES.lineDiagonal14,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(-1, 1) / 16,
					size = Vector2.new(14, 14) / 16,
					angle = TAU / 4
				}
			}
		}
	},

	arrowBounceHorizontal = AnimatedIcon {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.6,
		layers = {
			Layer {
				imageUrl = IMAGES.arrowDiagonal8,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(3, -1) / 16,
					size = Vector2.new(8, 8) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(3 - 5, -1 + 5) / 16,
						size = Vector2.new(8, 8) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = IMAGES.square,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(-4, 6) / 16,
					size = Vector2.new(8, 8) / 16,
					angle = 0
				}
			},
			Layer {
				imageUrl = IMAGES.private.arrowBounceHorizontal.floorAndIncoming,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.zero,
					size = Vector2.new(14, 10) / 16,
					angle = 0
				}
			}
		}
	},

	pointJoinStraight = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.6,
		layers = {
			Layer {
				imageUrl = IMAGES.lineDiagonal14,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.zero,
					size = Vector2.new(14, 14) / 16,
					angle = 0
				}
			},
			Layer {
				imageUrl = IMAGES.square,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(9, -9) / 16,
					size = Vector2.new(8, 8) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(9 - 5, -9 + 5) / 16,
						size = Vector2.new(8, 8) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = IMAGES.square,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(-9, 9) / 16,
					size = Vector2.new(8, 8) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-9 + 5, 9 - 5) / 16,
						size = Vector2.new(8, 8) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(5.5, -5.5) / 16,
					size = Vector2.new(3, 3) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(5.5 - 5, -5.5 + 5) / 16,
						size = Vector2.new(3, 3) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(-5.5, 5.5) / 16,
					size = Vector2.new(3, 3) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-5.5 + 5, 5.5 - 5) / 16,
						size = Vector2.new(3, 3) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			}
		}
	},

	sphereShadow = {
		fallbackUrls = {
			primary = "",
			secondary = ""
		},
		duration = 0.6,
		layers = {
			Layer {
				imageUrl = IMAGES.circle,
				colour = "secondary",
				restTransform = Transform {
					centre = Vector2.new(0, 4.5) / 16,
					size = Vector2.new(12, 5) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 4.5) / 16,
						size = Vector2.new(12, 5) / 16 * 0.5,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(0, -2) / 16,
					size = Vector2.new(12, 12) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, -2) / 16,
						size = Vector2.new(7, 7) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, -2) / 16,
					size = Vector2.new(10, 10) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, -2) / 16,
						size = Vector2.new(5, 5) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			}
		}
	},

	magnifyingGlass = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.6,
		layers = {
			Layer {
				imageUrl = IMAGES.circle,
				colour = "overlay",
				restTransform = Transform {
					centre = Vector2.new(-2.5, -2.5) / 16,
					size = Vector2.new(5, 5) / 16,
					angle = 0
				},
			},
			Layer {
				imageUrl = "",
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = TAU / 3
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = TAU / 3
					},
					action = "boomerang"
				}
			}
		}
	},

	ellipsisVertical = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, -16) / 16,
					size = Vector2.new(2, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, -4) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, -4) / 16,
					size = Vector2.new(2, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(2, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 4) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 4) / 16,
					size = Vector2.new(2, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 16) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
		},
	},

	ellipsisHorizontal = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(-16, 0) / 16,
					size = Vector2.new(2, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-4, 0) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(-4, 0) / 16,
					size = Vector2.new(2, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(2, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(4, 0) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(4, 0) / 16,
					size = Vector2.new(2, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(16, 0) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
		},
	},

	arrowUpSmall = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, -4) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
		}
	},

	arrowDownSmall = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 4) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
		}
	},

	arrowLeftSmall = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = -math.pi/2
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-4, 0) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = -math.pi/2
					},
					action = "boomerang"
				}
			},
		}
	},

	arrowRightSmall = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = math.pi/2
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(4, 0) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = math.pi/2
					},
					action = "boomerang"
				}
			},
		}
	},

	octagonX = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(14, 14) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(1, 0) / 16,
						size = Vector2.new(14, 14) / 16,
						angle = 0
					},
					action = "shake"
				}
			},
			Layer {
				imageUrl = "",
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(8, 8) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(4, 0) / 16,
						size = Vector2.new(8, 8) / 16,
						angle = 0
					},
					action = "shake"
				}
			},
		}
	},

	shieldX = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(12, 14) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(2, 0) / 16,
						size = Vector2.new(12, 14) / 16,
						angle = 0
					},
					action = "shake"
				}
			},
			Layer {
				imageUrl = "",
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(8, 8) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(4, 0) / 16,
						size = Vector2.new(8, 8) / 16,
						angle = 0
					},
					action = "shake"
				}
			},
		}
	},

	xSmall = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = TAU / -2
					},
					action = "meet"
				}
			}
		}
	},

	cog = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = TAU / -2
					},
					action = "meet"
				}
			}
		}
	},

	toggle = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.5,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(4, 0) / 16,
					size = Vector2.new(6, 6) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-4, 0) / 16,
						size = Vector2.new(6, 6) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
		}
	},

	circleISerif = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.5,
		layers = {
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(14, 14) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 2) / 16,
						size = Vector2.new(10, 10) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = "",
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(0, 1.5) / 16,
					size = Vector2.new(4, 5) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 3) / 16,
						size = Vector2.new(4, 2) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(0, -3) / 16,
					size = Vector2.new(2, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			}
		}
	},

	triangleExclaim = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, -1) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = "",
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(0, -0.75) / 16,
					size = Vector2.new(2, 4.5) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, -3.75) / 16,
						size = Vector2.new(2, 4.5) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = IMAGES.circle,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(0, 4) / 16,
					size = Vector2.new(2, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			}
		}
	},

	sparkles = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.6,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(2.5, -2.5) / 16,
					size = Vector2.new(9, 9) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(2.5, 2.5) / 16,
						size = Vector2.new(9, 9) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(-3.5, 3.5) / 16,
					size = Vector2.new(7, 7) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-3.5, -3.5) / 16,
						size = Vector2.new(7, 7) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			}
		}
	},

	lock = {
		fallbackUrls = {
			primary = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(1, 0) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = TAU / 24
					},
					action = "shake"
				}
			}
		}
	},

	circleArrowsClockwise = {
		fallbackUrls = {
			primary = "",
			overlay = ""
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = IMAGES.circle,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(8, 8) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(4, 4) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = "",
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = TAU / -2
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = "",
				colour = "overlay",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(16, 16) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(16, 16) / 16,
						angle = TAU / -2
					},
					action = "meet"
				}
			}
		}
	},

	cubeCorners = {
		fallbackUrls = {
			primary = "",
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = IMAGES.cube8,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(8, 8) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(6, 6) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			
			Layer {
				imageUrl = IMAGES.corner,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(5, -5) / 16,
					size = Vector2.new(4, 4) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(5, 5) / 16,
						size = Vector2.new(4, 4) / 16,
						angle = TAU / -4
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = IMAGES.corner,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(5, 5) / 16,
					size = Vector2.new(4, 4) / 16,
					angle = TAU / -4
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-5, 5) / 16,
						size = Vector2.new(4, 4) / 16,
						angle = 2 * TAU / -4
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = IMAGES.corner,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(-5, 5) / 16,
					size = Vector2.new(4, 4) / 16,
					angle = 2 * TAU / -4
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-5, -5) / 16,
						size = Vector2.new(4, 4) / 16,
						angle = 3 * TAU / -4
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = IMAGES.corner,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(-5, -5) / 16,
					size = Vector2.new(4, 4) / 16,
					angle = 3 * TAU / -4
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(5, -5) / 16,
						size = Vector2.new(4, 4) / 16,
						angle = 4 * TAU / -4
					},
					action = "meet"
				}
			},
		}
	},

	personPose = {
		fallbackUrls = {
			primary = "",
		},
		duration = 0.5,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(10, 14) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, -1) / 16,
						size = Vector2.new(10, 14) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(3, -1) / 16,
					size = Vector2.new(6, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(3.5, -3.5) / 16,
						size = Vector2.new(6, 2) / 16,
						angle = TAU / 6
					},
					action = "boomerang"
				}
			},
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(-3, -1) / 16,
					size = Vector2.new(6, 2) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-3.5, -3.5) / 16,
						size = Vector2.new(6, 2) / 16,
						angle = TAU / -6
					},
					action = "boomerang"
				}
			},
		}
	},

	rectCaret = {
		fallbackUrls = {
			primary = "",
			overlay = "",
		},
		duration = 0.5,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(0, 0) / 16,
					size = Vector2.new(14, 8) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(0, 0) / 16,
						size = Vector2.new(14, 4) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},

			Layer {
				imageUrl = IMAGES.square,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(-2.5, 0) / 16,
					size = Vector2.new(3, 10) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(4.5, 0) / 16,
						size = Vector2.new(3, 10) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},

			Layer {
				imageUrl = "",
				colour = "overlay",
				restTransform = Transform {
					centre = Vector2.new(-2.5, 0) / 16,
					size = Vector2.new(7, 14) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(4.5, 0) / 16,
						size = Vector2.new(7, 14) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
		}
	},

	windows = {
		fallbackUrls = {
			primary = "",
			secondary = "",
		},
		duration = 0.6,
		layers = {
			Layer {
				imageUrl = IMAGES.windowMid,
				colour = "secondary",
				restTransform = Transform {
					centre = Vector2.new(-2, 2) / 16,
					size = Vector2.new(10, 10) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-2, -3) / 16,
						size = Vector2.new(10, 10) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},

			Layer {
				imageUrl = IMAGES.square12Round2Dot5,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(2, -2) / 16,
					size = Vector2.new(12, 12) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(2, 3) / 16,
						size = Vector2.new(12, 12) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},

			Layer {
				imageUrl = IMAGES.windowMid,
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(2, -2) / 16,
					size = Vector2.new(10, 10) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(2, 3) / 16,
						size = Vector2.new(10, 10) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},
		}
	},

	rocket = {
		fallbackUrls = {
			primary = "",
			secondary = "",
		},
		duration = 0.4,
		layers = {
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(-3, -2.5) / 16,
					size = Vector2.new(8, 3) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(3, -2.5) / 16,
						size = Vector2.new(0, 3) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(3, -2.5) / 16,
					size = Vector2.new(0, 3) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-3, -2.5) / 16,
						size = Vector2.new(8, 3) / 16,
						angle = 0
					},
					action = "meet"
				}
			},

			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(2.5, 3) / 16,
					size = Vector2.new(3, 8) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(2.5, -3) / 16,
						size = Vector2.new(3, 0) / 16,
						angle = 0
					},
					action = "meet"
				}
			},
			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(2.5, -3) / 16,
					size = Vector2.new(3, 0) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(2.5, 3) / 16,
						size = Vector2.new(3, 8) / 16,
						angle = 0
					},
					action = "meet"
				}
			},

			Layer {
				imageUrl = "",
				colour = "secondary",
				restTransform = Transform {
					centre = Vector2.new(-4, 4) / 16,
					size = Vector2.new(4, 4) / 16,
					angle = 0
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-2, 2) / 16,
						size = Vector2.new(2, 2) / 16,
						angle = 0
					},
					action = "boomerang"
				}
			},

			Layer {
				imageUrl = "",
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(2, -2) / 16,
					size = Vector2.new(12, 12) / 16,
					angle = 0
				}
			},

			Layer {
				imageUrl = "",
				colour = "primary",
				restTransform = Transform {
					centre = Vector2.new(2, -2) / 16,
					size = Vector2.new(10, 10) / 16,
					angle = 0
				}
			},

			Layer {
				imageUrl = IMAGES.circle,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(2.5, -2.5) / 16,
					size = Vector2.new(3, 3) / 16,
					angle = -TAU / 8
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(-2.5, -7.5) / 16,
						size = Vector2.new(0, 3) / 16,
						angle = -TAU / 8
					},
					action = "meet"
				}
			},

			Layer {
				imageUrl = IMAGES.circle,
				colour = "background",
				restTransform = Transform {
					centre = Vector2.new(7.5, 2.5) / 16,
					size = Vector2.new(0, 3) / 16,
					angle = -TAU / 8
				},
				motion = Motion {
					type = "simple",
					goalTransform = Transform {
						centre = Vector2.new(2.5, -2.5) / 16,
						size = Vector2.new(3, 3) / 16,
						angle = -TAU / 8
					},
					action = "meet"
				}
			}
		}
	},
}
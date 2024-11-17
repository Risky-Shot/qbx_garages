return {
    autoRespawn = true, -- True == auto respawn cars that are outside into your garage on script restart, false == does not put them into your garage and players have to go to the impound
    warpInVehicle = false, -- If false, player will no longer warp into vehicle upon taking the vehicle out.
    doorsLocked = true, -- If true, the doors will be locked upon taking the vehicle out.
    distanceCheck = 5.0, -- The distance that needs to bee clear to let the vehicle spawn, this prevents vehicles stacking on top of each other
    ---calculates the automatic impound fee.
    ---@param vehicleId integer
    ---@param modelName string
    ---@return integer fee
    calculateImpoundFee = function(vehicleId, modelName)
        local vehCost = VEHICLES[modelName].price
        return qbx.math.round(vehCost * 0.02) or 0
    end,

    -- Default Garage For When Someone is removed from Parking Access
    -- Must be a valid from below
    defaultGarage = 'motelgarage',

    ---@class GarageBlip
    ---@field name? string -- Name of the blip. Defaults to garage label.
    ---@field coords? vector3 Blip Coords Of Garage
    ---@field sprite? number -- Sprite for the blip. Defaults to 357
    ---@field color? number -- Color for the blip. Defaults to 3.

    ---The place where the player can access the garage and spawn a car
    ---@class AccessPoint
    ---@field coords vector4 where the garage menu can be accessed from
    ---@field spawn? vector4 where the vehicle will spawn. Defaults to coords
    ---@field dropPoint? vector3 where a vehicle can be stored, Defaults to spawn or coords

    ---@class GarageConfig
    ---@field label string -- Label for the garage
    ---@field type? GarageType -- Optional special type of garage. Currently only used to mark DEPOT garages.
    ---@field vehicleType VehicleType -- Vehicle type
    ---@field blip? GarageBlip
    ---@field groups? string | string[] | table<string, number> job/gangs that can access the garage
    ---@field shared? boolean defaults to false. Shared garages give all players with access to the garage access to all vehicles in it. If shared is off, the garage will only give access to player's vehicles which they own.
    ---@field states? VehicleState | VehicleState[] if set, only vehicles in the given states will be retrievable from the garage. Defaults to GARAGED.
    ---@field skipGarageCheck? boolean if true, returns vehicles for retrieval regardless of if that vehicle's garage matches this garage's name
    ---@field canAccess? fun(source: number): boolean checks access as an additional guard clause. Other filter fields still need to pass in addition to this function.
    ---@field accessPoints AccessPoint[]

    ---@type table<string, GarageConfig>
    garages = {
        -- Public Garages
        motelgarage = {
            label = 'Motel Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                coords = vec3(275.58, -344.74, 45.17),
                sprite = 357,
                color = 3,
            },
            accessPoints = {
                {
                    coords = vec4(275.58, -344.74, 45.17, 70.0),
                }
            },
        },
        sapcounsel = {
            label = 'San Andreas Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(-330.67, -781.12, 33.96)
            },
            accessPoints = {
                {
                    coords = vec4(-330.67, -781.12, 33.96, 40.46),
                }
            },
        },
        spanishave = {
            label = 'Spanish Ave Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(-1160.46, -741.04, 19.95)
            },
            accessPoints = {
                {
                    coords = vec4(-1160.46, -741.04, 19.95, 41.26),
                }
            },
        },
        caears24 = {
            label = 'Caears 24 Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(68.08, 13.15, 69.21)
            },
            accessPoints = {
                {
                    coords = vec4(68.08, 13.15, 69.21, 160.44),
                },
            },
        },
        littleseoul = {
            label = 'Little Seoul Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(-463.51, -808.2, 30.54)
            },
            accessPoints = {
                {
                    coords = vec4(-463.51, -808.2, 30.54, 0.0),
                }
            },
        },
        lagunapi = {
            label = 'Laguna Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(363.85, 297.97, 103.5)
            },
            accessPoints = {
                {
                    coords = vec4(363.85, 297.97, 103.5, 341.39),
                }
            },
        },
        airportp = {
            label = 'Airport Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(-796.07, -2023.26, 9.17)
            },
            accessPoints = {
                {
                    coords = vec4(-796.07, -2023.26, 9.17, 55.18),
                }
            },
        },
        beachp = {
            label = 'Beach Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(-1184.21, -1509.65, 4.65)
            },
            accessPoints = {
                {
                    coords = vec4(-1184.21, -1509.65, 4.65, 303.72),
                }
            },
        },
        themotorhotel = {
            label = 'The Motor Hotel Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(1137.77, 2663.54, 37.9)
            },
            accessPoints = {
                {
                    coords = vec4(1137.77, 2663.54, 37.9, 0.0),
                }
            },
        },
        liqourparking = {
            label = 'Liqour Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(960.68, 3609.32, 32.98)
            },
            accessPoints = {
                {
                    coords = vec4(960.68, 3609.32, 32.98, 268.97),
                }
            },
        },
        shoreparking = {
            label = 'Shore Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(1726.9, 3710.38, 34.26)
            },
            accessPoints = {
                {
                    coords = vec4(1726.9, 3710.38, 34.26, 22.54),
                }
            },
        },
        haanparking = {
            label = 'Bell Farms Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(78.34, 6418.74, 31.28)
            },
            accessPoints = {
                {
                    coords = vec4(78.34, 6418.74, 31.28, 0),
                }
            },
        },
        dumbogarage = {
            label = 'Dumbo Private Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(157.26, -3240.00, 7.00)
            },
            accessPoints = {
                {
                    coords = vec4(157.26, -3240.00, 7.00, 0),
                }
            },
        },
        pillboxgarage = {
            label = 'Pillbox Garage Parking',
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Public Parking',
                sprite = 357,
                color = 3,
                coords = vec3(218.66, -804.08, 30.75)
            },
            accessPoints = {
                {
                    coords = vec4(218.66, -804.08, 30.75, 65.69),
                }
            },
        },
        intairport = {
            label = 'Airport Hangar',
            vehicleType = VehicleType.AIR,
            blip = {
                name = 'Hangar',
                sprite = 360,
                color = 3,
                coords = vec3(-1025.34, -3017.0, 13.95)
            },
            accessPoints = {
                {
                    coords = vec4(-1025.34, -3017.0, 13.95, 331.99),
                }
            },
        },
        higginsheli = {
            label = 'Higgins Helitours',
            vehicleType = VehicleType.AIR,
            blip = {
                name = 'Hangar',
                sprite = 360,
                color = 3,
                coords = vec3(-722.12, -1472.74, 5.0)
            },
            accessPoints = {
                {
                    coords = vec4(-722.12, -1472.74, 5.0, 140.0),
                }
            },
        },
        airsshores = {
            label = 'Sandy Shores Hangar',
            vehicleType = VehicleType.AIR,
            blip = {
                name = 'Hangar',
                sprite = 360,
                color = 3,
                coords = vec3(1757.74, 3296.13, 41.15)
            },
            accessPoints = {
                {
                    coords = vec4(1757.74, 3296.13, 41.15, 142.6),
                }
            },
        },
        lsymc = {
            label = 'LSYMC Boathouse',
            vehicleType = VehicleType.SEA,
            blip = {
                name = 'Boathouse',
                sprite = 356,
                color = 3,
                coords = vec3(-794.64, -1510.89, 1.6)
            },
            accessPoints = {
                {
                    coords = vec4(-794.64, -1510.89, 1.6, 201.55),
                }
            },
        },
        paleto = {
            label = 'Paleto Boathouse',
            vehicleType = VehicleType.SEA,
            blip = {
                name = 'Boathouse',
                sprite = 356,
                color = 3,
                coords = vec3(-277.4, 6637.01, 7.5)
            },
            accessPoints = {
                {
                    coords = vec4(-277.4, 6637.01, 7.5, 40.51),
                }
            },
        },
        millars = {
            label = 'Millars Boathouse',
            vehicleType = VehicleType.SEA,
            blip = {
                name = 'Boathouse',
                sprite = 356,
                color = 3,
                coords = vec3(1299.02, 4216.42, 33.91)
            },
            accessPoints = {
                {
                    coords = vec4(1299.02, 4216.42, 33.91, 166.8),
                }
            },
        },

        -- Job Garages
        police = {
            label = 'Police',
            vehicleType = VehicleType.CAR,
            groups = 'police',
            accessPoints = {
                {
                    coords = vec4(454.6, -1017.4, 28.4, 0),
                }
            },
        },

        -- Gang Garages
        ballas = {
            label = 'Ballas',
            vehicleType = VehicleType.CAR,
            groups = 'ballas',
            accessPoints = {
                {
                    coords = vec4(98.50, -1954.49, 20.84, 0),
                }
            },
        },
        families = {
            label = 'La Familia',
            vehicleType = VehicleType.CAR,
            groups = 'families',
            accessPoints = {
                {
                    coords = vec4(-811.65, 187.49, 72.48, 0),
                }
            },
        },
        lostmc = {
            label = 'Lost MC',
            vehicleType = VehicleType.CAR,
            groups = 'lostmc',
            accessPoints = {
                {
                    coords = vec4(957.25, -129.63, 74.39, 0),
                }
            },
        },
        cartel = {
            label = 'Cartel',
            vehicleType = VehicleType.CAR,
            groups = 'cartel',
            accessPoints = {
                {
                    coords = vec4(1407.18, 1118.04, 114.84, 0),
                }
            },
        },

        -- Impound Lots
        impoundlot = {
            label = 'Impound Lot',
            type = GarageType.DEPOT,
            states = {VehicleState.OUT, VehicleState.IMPOUNDED},
            skipGarageCheck = true,
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Impound Lot',
                sprite = 68,
                color = 3,
                coords = vec3(400.45, -1630.87, 29.29)
            },
            accessPoints = {
                {  
                    coords = vec4(400.45, -1630.87, 29.29, 228.88),
                }
            },
        },
        airdepot = {
            label = 'Air Depot',
            type = GarageType.DEPOT,
            states = {VehicleState.OUT, VehicleState.IMPOUNDED},
            skipGarageCheck = true,
            vehicleType = VehicleType.AIR,
            blip = {
                name = 'Air Depot',
                sprite = 359,
                color = 3,
                coords = vec3(-1244.35, -3391.39, 13.94)
            },
            accessPoints = {
                {
                    coords = vec4(-1244.35, -3391.39, 13.94, 59.26),
                }
            },
        },
        seadepot = {
            label = 'LSYMC Depot',
            type = GarageType.DEPOT,
            states = {VehicleState.OUT, VehicleState.IMPOUNDED},
            skipGarageCheck = true,
            vehicleType = VehicleType.SEA,
            blip = {
                name = 'LSYMC Depot',
                sprite = 356,
                color = 3,
                coords = vec3(-772.71, -1431.11, 1.6)
            },
            accessPoints = {
                {
                    coords = vec4(-772.71, -1431.11, 1.6, 48.03),
                }
            },
        },

        -- Parking Slots
        parking_strawberry = {
            label = "Med Center Parking",
            type = GarageType.PARKING,
            vehicleType = VehicleType.CAR,
            blip = {
                name = 'Med Center Parking',
                sprite = 369,
                color = 4,
                coords = vec3(397.7771, -1341.2992, 31.0110)
            },
            accessPoints = {
                [1] = {
                    coords = vec4(397.7771, -1341.2992, 31.0110, 323.2500)
                },
                [2] = {
                    coords = vec4(392.7447, -1336.1603, 31.8219, 319.7466)
                }
            }
        }
    },


}

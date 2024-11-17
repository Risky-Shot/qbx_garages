local config = require 'config.client'
if not config.enableClient then return end
local VEHICLES = exports.qbx_core:GetVehiclesByName()

---@enum ProgressColor
local ProgressColor = {
    GREEN = 'green.5',
    YELLOW = 'yellow.5',
    RED = 'red.5'
}

---@param percent number
---@return string
local function getProgressColor(percent)
    if percent >= 75 then
        return ProgressColor.GREEN
    elseif percent > 25 then
        return ProgressColor.YELLOW
    else
        return ProgressColor.RED
    end
end

local VehicleCategory = {
    all = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22},
    car = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 17, 18, 19, 20, 22},
    air = {15, 16},
    sea = {14},
}

---@param category VehicleType
---@param vehicle number
---@return boolean
local function isOfType(category, vehicle)
    local classSet = {}

    for _, class in pairs(VehicleCategory[category]) do
        classSet[class] = true
    end

    return classSet[GetVehicleClass(vehicle)] == true
end

---@param vehicle number
local function kickOutPeds(vehicle)
    for i = -1, 5, 1 do
        local seat = GetPedInVehicleSeat(vehicle, i)
        if seat then
            TaskLeaveVehicle(seat, vehicle, 0)
        end
    end
end

local spawnLock = false

---@param vehicleId number
---@param garageName string
---@param accessPoint integer
local function takeOutOfGarage(vehicleId, garageName, accessPoint)
    if spawnLock then
        exports.qbx_core:Notify(locale('error.spawn_in_progress'))
    end
    spawnLock = true
    local success, result = pcall(function()
        if cache.vehicle then
            exports.qbx_core:Notify(locale('error.in_vehicle'))
            return
        end

        local netId = lib.callback.await('qbx_garages:server:spawnVehicle', false, vehicleId, garageName, accessPoint)
        if not netId then return end

        local veh = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(netId) then
                return NetToVeh(netId)
            end
        end)

        if veh == 0 then
            exports.qbx_core:Notify('Something went wrong spawning the vehicle', 'error')
            return
        end

        if config.engineOn then
            SetVehicleEngineOn(veh, true, true, false)
        end
    end)
    spawnLock = false
    assert(success, result)
end

---@param data {vehicle: PlayerVehicle, garageName: string, accessPoint: integer}
local function takeOutDepot(data)
    local success = lib.callback.await('qbx_garages:server:payDepotPrice', false, data.vehicle)
    if not success then
        exports.qbx_core:Notify(locale('error.not_enough'), 'error')
        return
    end

    takeOutOfGarage(data.vehicle, data.garageName, data.accessPoint)
end

---@param vehicle PlayerVehicle
---@param garageName string
---@param garageInfo GarageConfig
---@param accessPoint integer
local function displayVehicleInfo(vehicle, garageName, garageInfo, accessPoint)
    local engine = qbx.math.round(vehicle.props.engineHealth / 10)
    local body = qbx.math.round(vehicle.props.bodyHealth / 10)
    local engineColor = getProgressColor(engine)
    local bodyColor = getProgressColor(body)
    local fuelColor = getProgressColor(vehicle.props.fuelLevel)
    local vehicleLabel = ('%s %s'):format(VEHICLES[vehicle.modelName].brand, VEHICLES[vehicle.modelName].name)

    local options = {
        {
            title = locale('menu.information'),
            icon = 'circle-info',
            description = locale('menu.description', vehicleLabel, vehicle.props.plate, lib.math.groupdigits(vehicle.depotPrice)),
            readOnly = true,
        },
        {
            title = locale('menu.body'),
            icon = 'car-side',
            readOnly = true,
            progress = body,
            colorScheme = bodyColor,
        },
        {
            title = locale('menu.engine'),
            icon = 'oil-can',
            readOnly = true,
            progress = engine,
            colorScheme = engineColor,
        },
        {
            title = locale('menu.fuel'),
            icon = 'gas-pump',
            readOnly = true,
            progress = vehicle.props.fuelLevel,
            colorScheme = fuelColor,
        }
    }

    if vehicle.state == VehicleState.OUT then
        if garageInfo.type == GarageType.DEPOT then
            options[#options + 1] = {
                title = 'Take out',
                icon = 'fa-truck-ramp-box',
                description = ('$%s'):format(lib.math.groupdigits(vehicle.depotPrice)),
                arrow = true,
                onSelect = function()
                    takeOutDepot({
                        vehicle = vehicle,
                        garageName = garageName,
                        accessPoint = accessPoint,
                    })
                end,
            }
        else
            options[#options + 1] = {
                title = 'Your vehicle is already out...',
                icon = VehicleType.CAR,
                readOnly = true,
            }
        end
    elseif vehicle.state == VehicleState.GARAGED then
        options[#options + 1] = {
            title = locale('menu.take_out'),
            icon = 'car-rear',
            arrow = true,
            onSelect = function()
                takeOutOfGarage(vehicle.id, garageName, accessPoint)
            end,
        }
    elseif vehicle.state == VehicleState.IMPOUNDED then
        options[#options + 1] = {
            title = locale('menu.veh_impounded'),
            icon = 'building-shield',
            readOnly = true,
        }
    end

    lib.registerContext({
        id = 'vehicleList',
        title = garageInfo.label,
        menu = 'garageMenu',
        options = options,
    })

    lib.showContext('vehicleList')
end

---@param garageName string
---@param garageInfo GarageConfig
---@param accessPoint integer
local function openGarage(garageName, garageInfo, accessPoint)
    ---@type PlayerVehicle[]?
    local vehicleEntities = lib.callback.await('qbx_garages:server:getGarageVehicles', false, garageName)

    if not vehicleEntities then
        exports.qbx_core:Notify(locale('error.no_vehicles'), 'error')
        return
    end

    table.sort(vehicleEntities, function(a, b)
        return a.modelName < b.modelName
    end)

    local vehicles = {}

    for i = 1, #vehicleEntities do
        local vehicleEntity = vehicleEntities[i]

        vehicles[#vehicles + 1] = {
            id = vehicleEntity.id,
            manufacturerName = VEHICLES[vehicleEntity.modelName].brand,
            carName = VEHICLES[vehicleEntity.modelName].name,
            vehicleDetails = {
                {label = 'Engine', value = tostring(qbx.math.round(vehicleEntity.props.engineHealth / 10))},
                {label = 'Body', value = tostring(qbx.math.round(vehicleEntity.props.bodyHealth / 10))},
                {label = 'Fuel', value = tostring(vehicleEntity.props.fuelLevel)},
                garageInfo.type == GarageType.DEPOT and {label = 'Depot Price', value = lib.math.groupdigits(vehicleEntity.depotPrice)} or nil
            },
            garage = garageInfo.label,
            numberPlate = vehicleEntity.props.plate,
            depotPrice = garageInfo.type == GarageType.DEPOT and lib.math.groupdigits(vehicleEntity.depotPrice) or nil
        }
    end

    local garageData = {}
    garageData.garageId = garageName
    garageData.garageName = garageInfo.label
    garageData.garageType = garageInfo.type
    garageData.accessPoint = accessPoint

    SendReactMessage('Garages:Get:InitialData', {
        vehiclesData = vehicles,
        garageData = garageData
    })
    ToggleNuiFrame(true)
    --[[
        Send : 
            vehicles - having vehicles list
            garageType - type of garage used to change UI layout
    ]]--
end

local function fetchParkingVehicles(garageName, garageInfo, accessPoint)
    local sendData = {}

    sendData.garage = garageName
    sendData.accessPoint = accessPoint

    local vehicleEntities = lib.callback.await('qbx_garages:server:parkingFetchVehicles', false, sendData)

    if not vehicleEntities then
        return nil
    end

    table.sort(vehicleEntities, function(a, b)
        return a.modelName < b.modelName
    end)

    local vehicles = {}

    for i = 1, #vehicleEntities do
        local vehicleEntity = vehicleEntities[i]

        vehicles[#vehicles + 1] = {
            id = vehicleEntity.id,
            manufacturerName = VEHICLES[vehicleEntity.modelName].brand,
            carName = VEHICLES[vehicleEntity.modelName].name,
            vehicleDetails = {
                {label = 'Engine', value = tostring(qbx.math.round(vehicleEntity.props.engineHealth / 10))},
                {label = 'Body', value = tostring(qbx.math.round(vehicleEntity.props.bodyHealth / 10))},
                {label = 'Fuel', value = tostring(vehicleEntity.props.fuelLevel)},
                {label = 'Owner', value = tostring(vehicleEntity.citizenid)},
            },
            garage = garageInfo.label,
            numberPlate = vehicleEntity.props.plate,
            depotPrice = garageInfo.type == GarageType.DEPOT and lib.math.groupdigits(vehicleEntity.depotPrice) or nil
        }
    end

    return vehicles
end

local function openParking(garageName, garageInfo, accessPoint)
    if garageInfo.type ~= GarageType.PARKING then return end

    local vehicles = fetchParkingVehicles(garageName, garageInfo, accessPoint)

    if not vehicles then
        exports.qbx_core:Notify(locale('error.no_vehicles'), 'error')
        return
    end

    local garageData = {}
    garageData.garageId = garageName
    garageData.garageName = garageInfo.label
    garageData.garageType = garageInfo.type
    garageData.accessPoint = accessPoint

    local isOwner = lib.callback.await('qbx_garages:server:isOwnerOfParking', false, {garage = garageName, accessPoint = accessPoint})
    local playersData = lib.callback.await('qbx_garages:server:fetchAccessUsers', false, garageName, accessPoint)

    SendReactMessage('Garages:Get:InitialData', {
        vehiclesData = vehicles,
        garageData = garageData,
        isOwner = isOwner,
        playersData = playersData
    })

    ToggleNuiFrame(true)
    --[[
        Send : 
            vehicles : List of Vehicles In Garage
            garageType :  GarageType.PARKING
            isOwner : isOwner (Perms to add and remove)
    ]]

end

---@param vehicle number
---@param garageName string
---@param garage GarageConfig
---@param accessPointIndex number
local function parkVehicle(vehicle, garageName, garage, accessPointIndex)
    if GetVehicleNumberOfPassengers(vehicle) ~= 1 then
        if garage.type ~= GarageType.PARKING then
            local isParkable = lib.callback.await('qbx_garages:server:isParkable', false, garageName, NetworkGetNetworkIdFromEntity(vehicle))

            if not isParkable then
                exports.qbx_core:Notify(locale('error.not_owned'), 'error', 5000)
                return
            end

            kickOutPeds(vehicle)
            SetVehicleDoorsLocked(vehicle, 2)
            Wait(1500)
            lib.callback.await('qbx_garages:server:parkVehicle', false, NetworkGetNetworkIdFromEntity(vehicle), lib.getVehicleProperties(vehicle), garageName)
            exports.qbx_core:Notify(locale('success.vehicle_parked'), 'primary', 4500)
        else
            local isParkable = lib.callback.await('qbx_garages:server:isParkableParking', false, garageName, accessPointIndex, NetworkGetNetworkIdFromEntity(vehicle))

            if not isParkable then
                exports.qbx_core:Notify(locale('error.not_owned'), 'error', 5000)
                return
            end

            kickOutPeds(vehicle)
            SetVehicleDoorsLocked(vehicle, 2)
            lib.callback.await('qbx_garages:server:parkVehicleParking', false, NetworkGetNetworkIdFromEntity(vehicle), lib.getVehicleProperties(vehicle), garageName, accessPointIndex)
            exports.qbx_core:Notify(locale('success.vehicle_parked'), 'primary', 4500)
        end
    else
        exports.qbx_core:Notify(locale('error.vehicle_occupied'), 'error', 3500)
    end
end

---@param garage GarageConfig
---@return boolean
local function checkCanAccess(garage)
    if garage.groups and not exports.qbx_core:HasPrimaryGroup(garage.groups, QBX.PlayerData) then
        exports.qbx_core:Notify(locale('error.no_access'), 'error')
        return false
    end
    if cache.vehicle and not isOfType(garage.vehicleType, cache.vehicle) then
        exports.qbx_core:Notify(locale('error.not_correct_type'), 'error')
        return false
    end
    return true
end

---@param garageName string
---@param garage GarageConfig
---@param accessPoint AccessPoint
---@param accessPointIndex integer
local function createZones(garageName, garage, accessPoint, accessPointIndex)
    CreateThread(function()
        accessPoint.dropPoint = accessPoint.dropPoint or accessPoint.spawn
        local dropZone, coordsZone
        lib.zones.sphere({
            coords = accessPoint.coords,
            radius = 10,
            onEnter = function()
                -- Drop Point Handler
                if accessPoint.dropPoint and garage.type ~= GarageType.DEPOT then
                    dropZone = lib.zones.sphere({
                        coords = accessPoint.dropPoint,
                        radius = 1.5,
                        onEnter = function()
                            if not cache.vehicle then return end
                            lib.showTextUI(locale('info.park_e'))
                        end,
                        onExit = function()
                            lib.hideTextUI()
                        end,
                        inside = function()
                            if not cache.vehicle then return end
                            if IsControlJustReleased(0, 38) then
                                if not checkCanAccess(garage) then return end
                                parkVehicle(cache.vehicle, garageName)
                            end
                        end,
                        debug = config.debugPoly
                    })
                end
                coordsZone = lib.zones.sphere({
                    coords = accessPoint.coords,
                    radius = 1,
                    onEnter = function()
                        if accessPoint.dropPoint and cache.vehicle then return end
                        lib.showTextUI((garage.type == GarageType.DEPOT and locale('info.impound_e')) or (cache.vehicle and locale('info.park_e')) or locale('info.car_e'))
                    end,
                    onExit = function()
                        lib.hideTextUI()
                    end,
                    inside = function()
                        if accessPoint.dropPoint and cache.vehicle then return end
                        if IsControlJustReleased(0, 38) then
                            if not checkCanAccess(garage) then return end
                            -- Depot Handler For Public and Shared Garages
                            if cache.vehicle and garage.type ~= GarageType.DEPOT and garage.type ~= GarageType.PARKING then
                                print('Park Public/Shared/Group Garage', garageName)
                                parkVehicle(cache.vehicle, garageName, garage, accessPointIndex)
                            elseif cache.vehicle and garage.type == GarageType.PARKING then
                                print('Park Parking Vehicle', garageName, accessPointIndex)
                                parkVehicle(cache.vehicle, garageName, garage, accessPointIndex)
                            elseif garage.type == GarageType.PARKING then
                                -- Do not Remove Progressbar to increase server / script performance as spam may lead to performance issues
                                if lib.progressBar({
                                    duration = 2000,
                                    label = 'Opening Garage',
                                    useWhileDead = false,
                                    canCancel = true,
                                    disable = {
                                        car = true,
                                    },
                                }) then openParking(garageName, garage, accessPointIndex) end
                            else
                                -- Do not Remove Progressbar to increase server / script performance as spam may lead to performance issues
                                if lib.progressBar({
                                    duration = 2000,
                                    label = 'Opening Garage',
                                    useWhileDead = false,
                                    canCancel = true,
                                    disable = {
                                        car = true,
                                    },
                                }) then openGarage(garageName, garage, accessPointIndex) end -- To hide shared icon
                            end
                        end
                    end,
                    debug = config.debugPoly
                })
            end,
            onExit = function()
                if dropZone then
                    dropZone:remove()
                end
                if coordsZone then
                    print('Removed Coord Zone')
                    coordsZone:remove()
                end
            end,
            inside = function()
                if accessPoint.dropPoint then
                    config.drawDropOffMarker(accessPoint.dropPoint)
                end
                config.drawGarageMarker(accessPoint.coords.xyz)
            end,
            debug = config.debugPoly,
        })
    end)
end

---@param garageInfo GarageConfig
---@param accessPoint AccessPoint
local function createBlips(garageInfo)
    local blip = AddBlipForCoord(garageInfo.blip.coords.x, garageInfo.blip.coords.y, garageInfo.blip.coords.z)
    SetBlipSprite(blip, garageInfo.blip.sprite or 357)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.60)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, garageInfo.blip.color or 3)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(garageInfo.blip.name or garageInfo.label)
    EndTextCommandSetBlipName(blip)
end

local function createGarage(name, garage)
    local accessPoints = garage.accessPoints
    for i = 1, #accessPoints do
        local accessPoint = accessPoints[i]

        if garage.blip then
            createBlips(garage)
        end

        createZones(name, garage, accessPoint, i)
    end
end

local function createGarages()
    local garages = lib.callback.await('qbx_garages:server:getGarages')
    for name, garage in pairs(garages) do
        createGarage(name, garage)
    end
end

RegisterNetEvent('qbx_garages:client:garageRegistered', function(name, garage)
    createGarage(name, garage)
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    createGarages()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end
    createGarages()
end)

-- Callback to Add User To Parking Slot
RegisterNuiCallback("qbx_garages:addToParking", function(data, cb)
    local garageName = data.garageName
    local accessPoint = data.accessPoint
    local citizenid = data.citizenid

    local response = lib.callback.await('qbx_garages:server:addToParking', false, garageName, accessPoint, citizenid)

    print('addToParking', json.encode(response))
    if response.success then
        print('Added Success')
        local users = lib.callback.await('qbx_garages:server:fetchAccessUsers', false, garageName, accessPoint)
        print('Users', json.encode(users))
        SendReactMessage('Garages:refreshPlayers', users)
    end
    cb(response)
end)

-- Callback To Remove user From Parking Slot
RegisterNuiCallback("qbx_garages:removeFromParking", function(data, cb)
    local garageName = data.garageName
    local accessPoint = data.accessPoint
    local citizenid = data.citizenid

    local response = lib.callback.await('qbx_garages:server:removeFromParking', false, garageName, accessPoint, citizenid)

    if response.success then
        local users = lib.callback.await('qbx_garages:server:fetchAccessUsers', false, garageName, accessPoint)
        SendReactMessage('Garages:refreshPlayers', users)
    end
    cb(response)
end)

RegisterNuiCallback("qbx_garages:DriveVehicle", function(data, cb)
    print(json.encode(data))
    local garageName = data.garageName
    local garageType = data.garageType
    local accessPoint = data.accessPoint
    local vehicleId = data.vehicleId

    if not garageName or not garageType or not accessPoint or not vehicleId then return end

    if (garageType ==  GarageType.PARKING) then
        print('Parking')
        takeOutOfGarage(vehicleId, garageName, accessPoint)
    elseif (garageType == 'depot') then
        local depotData = {
            vehicle = vehicleId,
            garageName = garageName,
            accessPoint = accessPoint,
        }
        takeOutDepot(depotData)
    else 
        print('Other Garage')
        takeOutOfGarage(vehicleId, garageName, accessPoint)
    end
    ToggleNuiFrame(false)
end)

RegisterNUICallback("garages:closeUI", function(data, cb)
    ToggleNuiFrame(false)
end)
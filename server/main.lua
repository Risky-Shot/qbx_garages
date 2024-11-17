assert(lib.checkDependency('qbx_core', '1.19.0', true))
assert(lib.checkDependency('qbx_vehicles', '1.3.1', true))
lib.versionCheck('Qbox-project/qbx_garages')

---@class ErrorResult
---@field code string
---@field message string

---@class PlayerVehicle
---@field id number
---@field citizenid? string
---@field modelName string
---@field garage string
---@field state VehicleState
---@field depotPrice integer
---@field props table ox_lib properties table

Config = require 'config.server'
VEHICLES = exports.qbx_core:GetVehiclesByName()
Storage = require 'server.storage'
---@type table<string, GarageConfig>
Garages = Config.garages

lib.callback.register('qbx_garages:server:getGarages', function()
    return Garages
end)

---Returns garages for use server side.
local function getGarages()
    return Garages
end
exports('GetGarages', getGarages)


---@param name string
---@param config GarageConfig
local function registerGarage(name, config)
    Garages[name] = config
    TriggerClientEvent('qbx_garages:client:garageRegistered', -1, name, config)
    TriggerEvent('qbx_garages:server:garageRegistered', name, config)
end

exports('RegisterGarage', registerGarage)

---Sets the vehicle's garage. It is the caller's responsibility to make sure the vehicle is not currently spawned in the world, or else this may have no effect.
---@param vehicleId integer
---@param garageName string
---@return boolean success, ErrorResult?
local function setVehicleGarage(vehicleId, garageName)
    local garage = Garages[garageName]
    if not garage then
        return false, {
            code = 'not_found',
            message = string.format('garage name %s not found. Did you forget to register it?', garageName)
        }
    end

    local state = garage.type == GarageType.DEPOT and VehicleState.IMPOUNDED or VehicleState.GARAGED
    local numRowsAffected = Storage.setVehicleGarage(vehicleId, garageName, state)
    if numRowsAffected == 0 then
        return false, {
            code = 'no_rows_changed',
            message = string.format('no rows were changed for vehicleId=%s', vehicleId)
        }
    end
    return true
end

exports('SetVehicleGarage', setVehicleGarage)

---Sets the vehicle's price for retrieval at a depot. Only affects vehicles that are OUT or IMPOUNDED.
---@param vehicleId integer
---@param depotPrice integer
---@return boolean success, ErrorResult?
local function setVehicleDepotPrice(vehicleId, depotPrice)
    local numRowsAffected = Storage.setVehicleDepotPrice(vehicleId, depotPrice)
    if numRowsAffected == 0 then
        return false, {
            code = 'no_rows_changed',
            message = string.format('no rows were changed for vehicleId=%s', vehicleId)
        }
    end
    return true
end

exports('SetVehicleDepotPrice', setVehicleDepotPrice)

function FindPlateOnServer(plate)
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        if plate == GetVehicleNumberPlateText(vehicles[i]) then
            return true
        end
    end
end

---@param garage string
---@return GarageType?
function GetGarageType(garage)
    return Garages[garage]?.type
end

---@class PlayerVehiclesFilters
---@field citizenid? string
---@field states? VehicleState|VehicleState[]
---@field garage? string

---@param source number
---@param garageName string
---@return PlayerVehiclesFilters
function GetPlayerVehicleFilter(source, garageName)
    local player = exports.qbx_core:GetPlayer(source)
    local garage = Garages[garageName]
    local filter = {}
    filter.citizenid = not garage.shared and player.PlayerData.citizenid or nil
    filter.states = garage.states or VehicleState.GARAGED
    filter.garage = not garage.skipGarageCheck and garageName or nil
    return filter
end

local function getCanAccessGarage(player, garage)
    if garage.groups and not exports.qbx_core:HasPrimaryGroup(player.PlayerData.source, garage.groups) then
        return false
    end
    if garage.canAccess ~= nil and not garage.canAccess(player.PlayerData.source) then
        return false
    end
    return true
end

---@param playerVehicle PlayerVehicle
---@return VehicleType
function getVehicleType(playerVehicle)
    if VEHICLES[playerVehicle.modelName].category == 'helicopters' or VEHICLES[playerVehicle.modelName].category == 'planes' then
        return VehicleType.AIR
    elseif VEHICLES[playerVehicle.modelName].category == 'boats' then
        return VehicleType.SEA
    else
        return VehicleType.CAR
    end
end

---@param source number
---@param garageName string
---@return PlayerVehicle[]?
lib.callback.register('qbx_garages:server:getGarageVehicles', function(source, garageName)
    local player = exports.qbx_core:GetPlayer(source)
    local garage = Garages[garageName]
    if not getCanAccessGarage(player, garage) then return end
    local filter = GetPlayerVehicleFilter(source, garageName)
    local playerVehicles = exports.qbx_vehicles:GetPlayerVehicles(filter)
    local toSend = {}
    if not playerVehicles[1] then return end
    for _, vehicle in pairs(playerVehicles) do
        if not FindPlateOnServer(vehicle.props.plate) then
            local vehicleType = Garages[garageName].vehicleType
            if vehicleType == getVehicleType(vehicle) then
                toSend[#toSend + 1] = vehicle
            end
        end
    end
    return toSend
end)

---@param source number
---@param vehicleId string
---@param garageName string
---@return boolean
local function isParkable(source, vehicleId, garageName)
    local garageType = GetGarageType(garageName)
    --- DEPOTS are only for retrieving, not storing
    if garageType == GarageType.DEPOT then return false end
    if not vehicleId then return false end
    local player = exports.qbx_core:GetPlayer(source)
    local garage = Garages[garageName]
    if not getCanAccessGarage(player, garage) then
        return false
    end
    ---@type PlayerVehicle
    local playerVehicle = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)
    if getVehicleType(playerVehicle) ~= garage.vehicleType then
        return false
    end
    if not garage.shared then
        if playerVehicle.citizenid ~= player.PlayerData.citizenid then
            return false
        end
    end
    return true
end

lib.callback.register('qbx_garages:server:isParkable', function(source, garage, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local vehicleId = Entity(vehicle).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    return isParkable(source, vehicleId, garage)
end)

---@param source number
---@param netId number
---@param props table ox_lib vehicle props https://github.com/overextended/ox_lib/blob/master/resource/vehicleProperties/client.lua#L3
---@param garage string
lib.callback.register('qbx_garages:server:parkVehicle', function(source, netId, props, garage)
    assert(Garages[garage] ~= nil, string.format('Garage %s not found. Did you register this garage?', garage))
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local vehicleId = Entity(vehicle).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    local owned = isParkable(source, vehicleId, garage) --Check ownership
    if not owned then
        exports.qbx_core:Notify(source, locale('error.not_owned'), 'error')
        return
    end

    exports.qbx_vehicles:SaveVehicle(vehicle, {
        garage = garage,
        state = VehicleState.GARAGED,
        props = props
    })

    exports.qbx_core:DeleteVehicle(vehicle)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end
    Wait(100)
    if Config.autoRespawn then
        Storage.moveOutVehiclesIntoGarages()
    end
end)

---@param vehicleId string
---@return boolean? success true if successfully paid
lib.callback.register('qbx_garages:server:payDepotPrice', function(source, vehicleId)
    local player = exports.qbx_core:GetPlayer(source)
    local cashBalance = player.PlayerData.money.cash
    local bankBalance = player.PlayerData.money.bank

    local vehicle = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)
    local depotPrice = vehicle.depotPrice
    if not depotPrice or depotPrice == 0 then return true end
    if cashBalance >= depotPrice then
        player.Functions.RemoveMoney('cash', depotPrice, 'paid-depot')
        return true
    elseif bankBalance >= depotPrice then
        player.Functions.RemoveMoney('bank', depotPrice, 'paid-depot')
        return true
    end
end)

---------------------------------------------------
--------------PARKING------------------------------
---------------------------------------------------
function CanAccessParkingSpot(citizenid, garageName, accessPoint, checkOwner)
    local data
    if checkOwner then
        data = MySQL.single.await('SELECT `id` FROM `garages` WHERE `garage` = ? AND `accessPoint` = ? AND `citizenid` = ? AND `isOwner` = 1', {
            garageName, accessPoint, citizenid
        })
    else
        data = MySQL.single.await('SELECT `id` FROM `garages` WHERE `garage` = ? AND `accessPoint` = ? AND `citizenid` = ?', {
            garageName, accessPoint, citizenid
        })
    end

    if data then return true end

    return false
end

lib.callback.register('qbx_garages:server:canAccessSpot', function(source, data)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return {success = false, message = 'invalid_player'} end

    local citizenid = player.PlayerData.citizenid

    if not data.garage or not data.accessPoint then return {success = false, message = 'invalid_garage'} end

    local garage = Garages[data.garage]

    -- Failed to Fetch Garage or Not Parking Garage
    if not garage or garage.type ~= GarageType.PARKING then return {success = false, message = 'invalid_garage'} end

    if CanAccessParkingSpot(citizenid, data.garage, accessPoint) then return {success = true} end

    return {success = false, message = 'no_access'}
end)

lib.callback.register('qbx_garages:server:parkingFetchVehicles', function(source, data)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return nil end

    local citizenid = player.PlayerData.citizenid

    if not data.garage or not data.accessPoint then return nil end

    local garage = Garages[data.garage]

    -- Failed to Fetch Garage or Not Parking Garage
    if not garage or garage.type ~= GarageType.PARKING then return nil end

    if not CanAccessParkingSpot(citizenid, data.garage, data.accessPoint) then return nil end

    local filter = {}

    filter.garage = data.garage..':'..data.accessPoint

    local Vehicles = exports.qbx_vehicles:GetPlayerVehicles(filter)

    local toSend = {}
    if not Vehicles[1] then return nil end
    for _, vehicle in pairs(Vehicles) do
        if not FindPlateOnServer(vehicle.props.plate) then
            local vehicleType = Garages[data.garage].vehicleType
            if vehicleType == getVehicleType(vehicle) then
                toSend[#toSend + 1] = vehicle
            end
        end
    end

    return toSend
end)

lib.callback.register('qbx_garages:server:buyAccessPoint', function(source, data)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return end

    local citizenid = player.PlayerData.citizenid

    if not data.garage or not data.accessPoint then return end

    -- Check if slot is already owned by someone else
    local alreadyOwned = MySQL.single.await('SELECT `id`, `citizenid` FROM `garages` WHERE `garage` = ? AND `accessPoint` = ?', {
        data.garage, data.accessPoint
    })

    if alreadyOwned then return {success = false, message = 'already_own_someone'} end

    -- Check if player already owns a slot in this lot (remove to allow multiple slots per parking)
    local ownsInLot = MySQL.scalar.await('SELECT `id` FROM `garages` WHERE `garage` = ? AND `citizenid` = ? AND `isOwner` = 1', {
        data.garage, citizenid
    })

    if ownsInLot then return {success = false, message = 'already_own_self'} end


    local id = MySQL.insert.await('INSERT INTO `garages` (garage, accessPoint, citizenid, isOwner) VALUES (?, ?, ?, ?)', {
        data.garage, data.accessPoint, citizenid, 1
    })

    if id then return {success = true, message = 'purchase_success'} end

    return {success = false, message = 'purchase_failed'}
end)

lib.callback.register('qbx_garages:server:availableSlots', function(source, garage)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return end

    local citizenid = player.PlayerData.citizenid

    if not garage then return end

    local purchasedSlots = MySQL.query.await('SELECT `accessPoint` FROM garages WHERE `garage` = ?', {garage})

    local usedSlots = {}

    for i=1, #purchasedSlots do
        usedSlots[#usedSlots + 1] = purchasedSlots[i].accessPoint
    end

    local AccessPoints = Garages[garage].accessPoints

    local toSend = {}

    for accessPoint, _ in pairs(AccessPoints) do
        if not lib.table.contains(usedSlots, accessPoint) then
            table.insert(toSend, {value = accessPoint, label = 'Slot :'..accessPoint})
        end
    end

    return toSend
end)

local function isParkableParking(source, vehicleId, garageName, accessPointIndex)
    local garageType = GetGarageType(garageName)
    --- DEPOTS are only for retrieving, not storing
    if garageType ~= GarageType.PARKING then return false end
    if not vehicleId then return false end
    local player = exports.qbx_core:GetPlayer(source)
    local garage = Garages[garageName]

    if not CanAccessParkingSpot(player.PlayerData.citizenid, garageName, accessPointIndex) then return false end

    ---@type PlayerVehicle
    local playerVehicle = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)
    if getVehicleType(playerVehicle) ~= garage.vehicleType then
        return false
    end
    return true
end

lib.callback.register('qbx_garages:server:isParkableParking', function(source, garageName, accessPointIndex, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local vehicleId = Entity(vehicle).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    
    return isParkableParking(source, vehicleId, garageName, accessPointIndex)
end)

lib.callback.register('qbx_garages:server:parkVehicleParking', function(source, netId, props, garageName, accessPointIndex)
    assert(Garages[garageName] ~= nil, string.format('Garage %s not found. Did you register this garage?', garageName))
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local vehicleId = Entity(vehicle).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))

    local owned = isParkableParking(source, vehicleId, garageName, accessPointIndex)

    if not owned then 
        exports.qbx_core:Notify(source, locale('error.not_owned'), 'error') 
        return false 
    end

    exports.qbx_vehicles:SaveVehicle(vehicle, {
        garage = garageName..":"..accessPointIndex,
        state = VehicleState.GARAGED,
        props = props
    })

    exports.qbx_core:DeleteVehicle(vehicle)
end)

lib.callback.register('qbx_garages:server:addToParking', function(source, garage, accessPoint, targetCid)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return {success = false, message = 'invalid_player'} end

    if not garage or not accessPoint or not targetCid then return {success = false, message = 'invalid_data'} end

    local target = exports.qbx_core:GetOfflinePlayer(targetCid)

    if not target then return {success = false, message = 'invalid_citizenid'} end

    -- Check if already having access to slot
    local data = MySQL.single.await('SELECT `id` FROM `garages` WHERE `garage` = ? AND `accessPoint` = ? AND `citizenid` = ?', {
        garage, accessPoint, targetCid
    })

    if data then return {success = false, message = 'already_access'} end

    local id = MySQL.insert.await('INSERT INTO `garages` (garage, accessPoint, citizenid, isOwner) VALUES (?, ?, ?, ?)', {
        garage, accessPoint, targetCid, 0
    })

    if id then return {success = true} end

    return {success = false, message = 'something_went_wrong'}
end)

lib.callback.register('qbx_garages:server:availableSlotsAccess', function(source, garage)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return end

    local citizenid = player.PlayerData.citizenid

    if not garage then return end

    local accessSlots = MySQL.query.await('SELECT `accessPoint` FROM garages WHERE `garage` = ? AND `citizenid` = ? AND `isOwner` = 0', {garage, citizenid})

    if #accessSlots < 1 then return end

    local toSend = {}

    for i=1, #accessSlots do
        table.insert(toSend, {value = accessSlots[i].accessPoint, label = "Slot : "..accessSlots[i].accessPoint})
    end
    
    return toSend
end)

function SendCarsToPublicGarage(citizenid, garage, accessPoint)
    local filter = {}

    filter.garage = garage..':'..accessPoint
    filter.citizenid = citizenid
    filter.states = 1

    local Vehicles = exports.qbx_vehicles:GetPlayerVehicles(filter)

    if not Vehicles[1] then return true end

    for _, vehicle in pairs(Vehicles) do
        local vehicleId = vehicle.id
        setVehicleGarage(vehicleId, Config.defaultGarage)
    end
end

lib.callback.register('qbx_garages:server:removeFromParking', function(source, garage, accessPoint, targetCid)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return {success = false, message = 'invalid_player'} end

    if not garage or not accessPoint or not targetCid then return {success = false, message = 'invalid_data'} end

    local target = exports.qbx_core:GetOfflinePlayer(targetCid)

    if not target then return {success = false, message = 'invalid_citizenid'} end

    -- Check if already having access to slot
    local data = MySQL.single.await('SELECT `id`, `isOwner` FROM `garages` WHERE `garage` = ? AND `accessPoint` = ? AND `citizenid` = ?', {
        garage, accessPoint, targetCid
    })

    if not data or data.isOwner == 1 then return {success = false, message = 'removal_failed'} end

    local id = MySQL.update.await('DELETE FROM `garages` WHERE `id` = ? and `citizenid` = ?', {
        data.id, targetCid
    })

    if id then 
        SendCarsToPublicGarage(targetCid, garage, accessPoint)
        return {success = true} 
    end

    return {success = false, message = 'something_went_wrong'}
end)

lib.callback.register('qbx_garages:server:isOwnerOfParking', function(source, data)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return {success = false, message = 'invalid_player'} end

    local citizenid = player.PlayerData.citizenid

    if not data.garage or not data.accessPoint then return false end

    local garage = Garages[data.garage]

    -- Failed to Fetch Garage or Not Parking Garage
    if not garage or garage.type ~= GarageType.PARKING then return false end

    if CanAccessParkingSpot(citizenid, data.garage, data.accessPoint, true) then return true end

    return false
end)

lib.callback.register('qbx_garages:server:fetchAccessUsers', function(source, garage, accessPoint)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return {success = false, message = 'invalid_player'} end

    local citizenid = player.PlayerData.citizenid

    if not garage or not accessPoint or not citizenid then return {success = false, message = 'invalid_data'} end

    local query = [[
        SELECT gr.citizenid as cid, p.fullName AS fullName, gr.isOwner as isOwner
            FROM garages gr 
            LEFT JOIN players p ON gr.citizenid = p.citizenid 
        WHERE 
            gr.garage = ? AND
            gr.accessPoint = ?
    ]]

    local users = MySQL.query.await(query, {garage, accessPoint})

    local toSend = {}

    if #users < 1 then print('Empty Table To Return') return toSend end

    for i=1, #users do    
        table.insert(toSend, {id = users[i].cid, name = users[i].fullName or "REMOVE ME", isOwner = users[i].isOwner})
    end

    return toSend
end)

lib.callback.register('qbx_garages:server:leaveAccessPoint', function(source, data)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return {success = false, message = 'invalid_player'} end

    local citizenid = player.PlayerData.citizenid

    if not data.garage or not data.accessPoint or not citizenid then return {success = false, message = 'invalid_data'} end

    -- Check if already having access to slot
    local sdata = MySQL.single.await('SELECT `id`, `isOwner` FROM `garages` WHERE `garage` = ? AND `accessPoint` = ? AND `citizenid` = ?', {
        data.garage, data.accessPoint, citizenid
    })

    if not sdata or sdata.isOwner == 1 then return {success = false, message = 'removal_failed'} end

    local id = MySQL.update.await('DELETE FROM `garages` WHERE `id` = ? and `citizenid` = ?', {
        sdata.id, citizenid
    })

    SendCarsToPublicGarage(citizenid, data.garage, data.accessPoint)

    if id then return {success = true} end

    return {success = false, message = 'something_went_wrong'}
end)
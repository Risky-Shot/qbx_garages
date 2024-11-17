local garageData = require 'config.parking'

local function OpenGarageBuy(garageName)
    local availableSlots = lib.callback.await('qbx_garages:server:availableSlots', false, garageName)

    if #availableSlots < 1 then 
        lib.notify({
            title = 'Parking Booth',
            type = "error",
            description = "No Slots Available"
        })
        return 
    end

    local input = lib.inputDialog('Parking Booth', {
        {
            type = "select", 
            label = 'Available Slots', 
            icon = "person-shelter",
            options = availableSlots, 
            required = true, clearable = false, searchable = true
        }
    })

    if not input then return end

    local data = {}

    data.garage = garageName
    data.accessPoint = input[1]

    local response = lib.callback.await('qbx_garages:server:buyAccessPoint', false, data)

    if response.success then 
        exports.qbx_core:Notify(locale('success.parking_success'), 'success', 5000)
    end
end

local function OpenLeaveSlot(garageName)
    local availableSlots = lib.callback.await('qbx_garages:server:availableSlotsAccess', false, garageName)

    if not availableSlots then 
        lib.notify({
            title = 'Parking Booth',
            type = "error",
            description = "No Slots Available"
        })
        return 
    end

    local input = lib.inputDialog('Parking Booth', {
        {
            type = "select", 
            label = 'Available Slots', 
            icon = "person-shelter",
            options = availableSlots, 
            required = true, clearable = false, searchable = true
        }
    })

    if not input then return end

    local data = {}

    data.garage = garageName
    data.accessPoint = input[1]

    local response = lib.callback.await('qbx_garages:server:leaveAccessPoint', false, data)

    if response.success then 
        exports.qbx_core:Notify(locale('success.parking_success'), 'success', 5000)
    end
end

local function SetupGarageTarget(garageInfo)
    exports.ox_target:addSphereZone({
        coords = garageInfo.panelLocation.coords,
        radius = garageInfo.panelLocation.radius,
        debug = true,
        options = {
            {
                label = "Buy Slot",
                distance = 1.5,
                onSelect = function()
                    OpenGarageBuy(garageInfo.garageName)
                end
            },
            {
                label = "Leave Slot",
                distance = 1.5,
                onSelect = function()
                    OpenLeaveSlot(garageInfo.garageName)
                end
            }
        }
    })
end

local function SetupGarages()
    for garage, garageInfo in pairs(garageData.locations) do
        local point = lib.points.new({
            coords = garageInfo.panelLocation.coords,
            distance = 20,
            data = garageInfo.panelLocation
        })

        function point:nearby()
            if self.currentDistance < 5.0 then
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z + 1.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.2, 0.2, 0.2, 148, 0, 211, 150, true, false, 0, true, nil, nil, false)
            end
        end

        function point:onEnter()
            lib.requestModel(`S_M_Y_Valet_01`, 10000)
            SetModelAsNoLongerNeeded(`S_M_Y_Valet_01`)

            self.data.ped = CreatePed(0, `S_M_Y_Valet_01`, self.data.coords.x, self.data.coords.y, self.data.coords.z-1, self.data.coords.w, false, false)

            TaskStartScenarioInPlace(self.data.ped, 'WORLD_HUMAN_GUARD_STAND', 0, true)
            FreezeEntityPosition(self.data.ped, true)
            SetEntityInvincible(self.data.ped, true)
            SetBlockingOfNonTemporaryEvents(self.data.ped, true)
            exports.ox_target:addLocalEntity(self.data.ped, {
                {
                    label = "Buy Slot",
                    distance = 1.5,
                    onSelect = function()
                        OpenGarageBuy(garageInfo.garageName)
                    end
                },
                {
                    label = "Leave Slot",
                    distance = 1.5,
                    onSelect = function()
                        OpenLeaveSlot(garageInfo.garageName)
                    end
                }
            })
        end

        function point:onExit()
            exports.ox_target:removeLocalEntity(self.data.ped)
            
            if DoesEntityExist(self.data.ped) then
                DeletePed(self.data.ped)
            end
            self.data.ped = nil
        end
    end
end

SetupGarages()
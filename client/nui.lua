function SendReactMessage(action, data)
    SendNUIMessage({
      action = action,
      data = data
    })
end

function ToggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
end

RegisterCommand('garage', function()
    ToggleNuiFrame(true)
end, false)

RegisterNUICallback('hideFrame', function(_, cb)
    ToggleNuiFrame(false)
    cb({})
end)
local Source = script.Parent.Parent
local Roact = require(Source.Roact)
local RoactStudioWidgets = require(Source.RoactStudioWidgets)
local App = require(script.Parent.Components.App)
local ComponentProvider = require(script.Parent.Components.ComponentProvider)
local ComponentManager = require(script.Parent.ComponentManager)
local DockWidgetPluginGui = require(script)

return function(plugin)
	local componentManager = ComponentManager.new()

	local propertiesGui = c(RoactStudioWidgets.DockWidgetPluginGui, {
		Name = "ComponentVisualizerProperties",
		Title = "Component Properties",
		InitialDockState = Enum.InitialDockState.Right,
		InitialEnable = false,
    })


	local addNewGui = c(RoactStudioWidgets.DockWidgetPluginGui, {
		Name = "ComponentVisualizerAddNew",
		Title = "Add component...",
		InitialDockState = Enum.InitialDockState.Float,
		InitialEnable = false,
		InitialEnabledShouldOverrideRestore = true,
		FloatingXSize = 300,
        FloatingYSize = 400,
        MinWidth = 300,
        MinHeight = 400,
    })

	componentManager.updated:connect(function(oldState, newState)
		local numSel = #newState.instances
		local prefix = "Component Properties"
		local title = prefix
		if numSel == 1 then
			local inst = newState.instances[1]
			title = string.format("%s - %s %q", prefix, inst.class, inst.name)
		elseif numSel >= 2 then
			title = string.format("%s - %i items", prefix, numSel)
		end
		propertiesGui.Title = title
		propertiesGui.Enabled = numSel > 0
	end)

	local element = Roact.createElement(ComponentProvider, {
		manager = componentManager,
	}, {
		App = Roact.createElement(App),
	})

	element = Roact.mount(element, propertiesGui, "Plugin")

	local toolbar = plugin:toolbar("Components")
	local addNewButton = plugin:button(toolbar, "Add new...", "Add a component to the selected objects.", "")
	addNewButton.Click:Connect(function()
		-- popup menu
		addNewGui.Enabled = true
	end)

	plugin:beforeUnload(function()
		componentManager:destroy()
		Roact.unmount(element)
	end)
end

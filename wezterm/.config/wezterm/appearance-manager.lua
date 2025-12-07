local M = {}

local wezterm = require("wezterm")
local act = wezterm.action

---@class AppearanceProfile
---@field display_name string Human-readable name of the appearance profile
---@field color_scheme string Name of the WezTerm color scheme (builtin or custom)
---@field background_image_path string directory of background images (relative to $HOME)
---@field background_image string Path to background image (relative to background_image_path)
---@field background_tint_opacity number Opacity of the color overlay (0.0-1.0)
---@field font string Font family name
---@field font_size number Font size in points

---@class AppearanceManagerOptions
---@field initial_profile string|nil Key of the profile to apply on startup
---@field profiles table<string, AppearanceProfile> Map of profile names to AppearanceProfile objects

local config_ref = nil
local active_profile_id = nil

---Helper to get scheme object from name
---@param color_scheme_name string Name of the color scheme
---@return table|nil scheme The color scheme table or nil if not found
local function get_scheme(color_scheme_name)
	-- Check custom schemes first
	if config_ref and config_ref.color_schemes and config_ref.color_schemes[color_scheme_name] then
		return config_ref.color_schemes[color_scheme_name]
	end
	-- Fall back to builtins
	return wezterm.color.get_builtin_schemes()[color_scheme_name]
end

---Build background configuration for an appearance profile
---@param profile AppearanceProfile Appearance profile parameters
---@return table background WezTerm background configuration
local function get_background_for_profile(profile, background_image)
	local scheme = get_scheme(profile.color_scheme)

	local bg_color = scheme and scheme.background or "#000000"
	return {
		-- First layer: the image (drawn first)
		{
			source = {
				File = wezterm.home_dir .. profile.background_image_path .. background_image,
			},
			width = "Cover",
			height = "Cover",
		},
		-- Second layer: a color tint (drawn on top of the image)
		{
			source = {
				-- Dynamically get the background color from the color scheme
				Color = bg_color,
			},
			-- Apply the desired opacity to this color layer
			opacity = profile.background_tint_opacity,
			height = "100%",
			width = "100%",
		},
	}
end

---Create a list of human-readable appearance profiles for the InputSelector
---@return table choices List of profile choices
local function get_profile_choices()
	local choices = {}
	wezterm.log_info("appearance-manager: get_profile_choices called")
	wezterm.log_info("appearance-manager: M.options.profiles = " .. wezterm.to_string(M.options.profiles))

	for name, profile in pairs(M.options.profiles) do
		local image_filename = profile.background_image:match("([^/]+)$") or profile.background_image

		table.insert(choices, {
			id = name,
			label = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "White" } },
				{ Text = profile.display_name or name },
				{ Attribute = { Intensity = "Normal" } },
				{ Text = "  " },
				{ Foreground = { AnsiColor = "Aqua" } },
				{
					Text = string.format(
						"scheme: %s | image: %s | font: %s %dpt | opacity: %.0f%%",
						profile.color_scheme,
						image_filename,
						profile.font,
						profile.font_size,
						profile.background_tint_opacity * 100
					),
				},
			}),
		})
	end

	wezterm.log_info("appearance-manager: total choices = " .. #choices)
	-- Sort alphabetically
	table.sort(choices, function(a, b)
		return a.id < b.id
	end)
	return choices
end

---Get background images in bg_image_path
---@param bg_image_path string Directory of background images to pick
---@return table choices List of image files
local function get_background_image_choices(bg_image_path)
	local choices = {}
	local bg_images = wezterm.home_dir .. bg_image_path .. "/*.{png,jpg,jpeg}"

	local success, files = pcall(wezterm.glob, bg_images)
	if success and files then
		for _, file in ipairs(files) do
			local filename = file:match("([^/]+)$")
			table.insert(choices, {
				id = filename,
				label = filename,
			})
		end
	else
		wezterm.log_error("appearance-manager: could not read images from " .. bg_images)
	end
	-- for file_name, profile in pairs()

	return choices
end

---Apply an appearance profile to a window
---@param window table WezTerm window object
---@param profile AppearanceProfile Appearance profile to apply
local function apply_profile(window, profile)
	local overrides = window:get_config_overrides() or {}

	overrides.background = get_background_for_profile(profile, profile.background_image)
	overrides.color_scheme = profile.color_scheme
	overrides.font = wezterm.font(profile.font)
	overrides.font_size = profile.font_size

	window:set_config_overrides(overrides)
end

---Apply a background image
---@param window table WezTerm window object
---@param profile AppearanceProfile AppearnceProfile to load background info from
---@param background_image string Path to background image to load
local function apply_background_image(window, profile, background_image)
	local overrides = window:get_config_overrides() or {}

	overrides.background = get_background_for_profile(profile, background_image)

	window:set_config_overrides(overrides)
end

---Register event handlers
local function register_events()
	-- APPEARANCE PROFILE SELECTION
	-- Register the event handler for appearance profile selection
	wezterm.on("appearance-manager.select-profile", function(window, pane)
		window:perform_action(
			act.InputSelector({
				title = "Select appearance profile",
				choices = get_profile_choices(),
				fuzzy = true,
				fuzzy_description = "Select appearance profile: ",
				action = wezterm.action_callback(function(inner_window, _pane, id, _label)
					if id then
						wezterm.emit("appearance-manager.apply-profile", inner_window, id)
					end
				end),
			}),
			pane
		)
	end)

	-- Event: Apply a specific appearance profile by id
	wezterm.on("appearance-manager.apply-profile", function(window, profile_id)
		local profile = M.options.profiles[profile_id]
		if profile then
			apply_profile(window, profile)
			active_profile_id = profile_id
			wezterm.log_info("appearance-manager: applied profile " .. profile_id)
		else
			wezterm.log_error("appearance-manager: profile not found: " .. tostring(profile_id))
		end
	end)

	------------------
	-- BACKGROUND IMAGE SELECTION

	-- Image InputSelector
	wezterm.on("appearance-manager.select-background-image", function(window, pane)
		local profile = M.options.profiles[active_profile_id]
		window:perform_action(
			act.InputSelector({
				title = "Select background image",
				choices = get_background_image_choices(profile.background_image_path),
				fuzzy = true,
				fuzzy_description = "Select background image: ",
				action = wezterm.action_callback(function(inner_window, _pane, id, _label)
					if id then
						wezterm.emit("appearance-manager.apply-background-image", inner_window, id)
					end
				end),
			}),
			pane
		)
	end)

	-- Apply selected image
	wezterm.on("appearance-manager.apply-background-image", function(window, background_image)
		if background_image then
			local profile = M.options.profiles[active_profile_id]
			apply_background_image(window, profile, background_image)
			wezterm.log_info("appearance-manager: applied background " .. background_image)
		else
			wezterm.log_error("appearance-manager: Image not found: " .. tostring(background_image))
		end
	end)
end

---Setup keybindings
---@param config table WezTerm config object
local function setup_keybindings(config)
	config.keys = config.keys or {}

	-- Appearance profile selector: Leader + p
	table.insert(config.keys, {
		key = "p",
		mods = "LEADER",
		action = act.EmitEvent("appearance-manager.select-profile"),
	})
    -- Change background image: Leader + b
	table.insert(config.keys, {
		key = "b",
		mods = "LEADER",
		action = act.EmitEvent("appearance-manager.select-background-image"),
	})
end

---Apply appearance manager configuration to WezTerm config
---@param config table WezTerm config object from config_builder()
---@param options AppearanceManagerOptions Appearance manager options
function M.apply_to_config(config, options)
	-- Store user options and config reference
	M.options = options
	config_ref = config

	-- Validate
	if not M.options.initial_profile then
		wezterm.log_error("appearance-manager: initial_profile is required")
		return
	end

	-- Set active_profile to initial_profile
	active_profile_id = M.options.initial_profile
	local profile = M.options.profiles[M.options.initial_profile]
	if not profile then
		wezterm.log_error("appearance-manager: profile '" .. M.options.initial_profile .. "' not found")
		return
	end

	wezterm.log_info("Background path: " .. M.options.profiles[M.options.initial_profile].background_image_path)

	config.background = get_background_for_profile(profile, profile.background_image)
	config.color_scheme = profile.color_scheme
	config.font = wezterm.font(profile.font)
	config.font_size = profile.font_size

	register_events()
	setup_keybindings(config)
end

return M

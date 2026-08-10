local config = {
	updateURL = "https://raw.githubusercontent.com/DankLife-Studios/scripts_version/Live/scripts_version.json",
	cronExpression = "0 * * * *",
	maxRetries = 3,
	retryDelay = 5000,
	serverInitDelay = 5000,
	originalScriptName = "Dank_Utils"
}

-- Global cache for graceful degradation: last known remote version.
local cachedRemoteVersion = nil
local lastReportedState = nil

local function printIfStateChanged(state, printFn)
	if lastReportedState == state then
		return
	end

	lastReportedState = state
	printFn()
end

-- Convert a version string (e.g., "1.2.3") into a comparable number.
local function versionToNumber(version)
	local major, minor, patch = string.match(version, "(%d+)%.(%d+)%.(%d+)")
	if major and minor and patch then
		return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
	else
		return nil
	end
end

-- Fetch the remote version from the JSON file with retry logic.
local function GetVersionFromJSON(callback)
	local scriptName = GetCurrentResourceName()

	local function tryFetch(attempt)
		PerformHttpRequest(config.updateURL, function(err, text, headers)
			if err == 200 and text then
				local jsonData = json.decode(text)
				if jsonData then
					local found = false
					for _, job in ipairs(jsonData) do
						if job.scriptName == scriptName then
							local remoteVer = job.version
							cachedRemoteVersion = remoteVer -- update our cache
							callback(remoteVer)
							found = true
							break
						end
					end
					if not found then
						callback(nil, "missing:" .. scriptName)
					end
				else
					callback(nil, "decode_failed")
				end
			else
				if attempt < config.maxRetries then
					SetTimeout(config.retryDelay, function()
						tryFetch(attempt + 1)
					end)
				else
					if cachedRemoteVersion then
						callback(cachedRemoteVersion)
					else
						callback(nil, "fetch_failed:" .. tostring(err))
					end
				end
			end
		end, "GET")
	end

	tryFetch(1)
end

-- Retrieve the local version from the resource manifest.
local function GetVersionFromManifest()
	local resourceName = GetCurrentResourceName()
	return GetResourceMetadata(resourceName, "version", 0)
		or GetResourceMetadata(resourceName, "script_version", 0)
end

local function reportComparison(resourceName, curVer, remoteVersion)
	if remoteVersion then
		local curVerNum = versionToNumber(curVer)
		local remoteVerNum = versionToNumber(remoteVersion)
		if curVerNum and remoteVerNum then
			if curVerNum == remoteVerNum then
				printIfStateChanged(("current:%s:remote:%s:status:current"):format(curVer, remoteVersion), function()
					print("^2[^6DankLife Gaming ^2- ^0" ..
						resourceName .. "] You are up to date. Current Version: " .. curVer .. "^0")
				end)
			elseif curVerNum > remoteVerNum then
				printIfStateChanged(("current:%s:remote:%s:status:ahead"):format(curVer, remoteVersion), function()
					print("^2[^6DankLife Gaming ^2- ^0" ..
						resourceName .. "] Holy Shit... How did you get this? Version: " .. curVer .. "^0")
				end)
			else
				printIfStateChanged(("current:%s:remote:%s:status:update"):format(curVer, remoteVersion), function()
					print(
						"^6--------------------------------------------------------------------------------------------------^0")
					print("^2[^6DankLife Gaming ^2- ^0" .. resourceName .. "] A new version is available.^0")
					print("^2[^6DankLife Gaming ^2- ^0" .. resourceName .. "] Current Version: " .. curVer .. "^0")
					print("^2[^6DankLife Gaming ^2- ^0" .. resourceName .. "] New Version: " .. remoteVersion .. "^0")
					print(
						"^6--------------------------------------------------------------------------------------------------^0")
				end)
			end
		else
			printIfStateChanged(("current:%s:remote:%s:status:invalid_format"):format(curVer, remoteVersion), function()
				print("^1[^6DankLife Gaming ^2- ^0Error: Invalid version format for comparison.^0")
			end)
		end
	else
		printIfStateChanged(("current:%s:remote:none:status:unavailable"):format(curVer), function()
			print("^1[^6DankLife Gaming ^2- ^0Could not retrieve remote version for " .. resourceName .. ".^0")
		end)
	end
end

-- Compare the local version with the remote version and print update messages.
local function CheckForUpdates()
	Wait(config.serverInitDelay)

	local resourceName = GetCurrentResourceName()
	local curVer = GetVersionFromManifest()
	if not curVer then
		printIfStateChanged("manifest:missing:" .. resourceName, function()
			print("^1[^6DankLife Gaming ^2- ^0Error: version not found in resource manifest for " .. resourceName .. "^0")
		end)
		return
	end

	GetVersionFromJSON(function(remoteVersion, errorState)
		if errorState == "missing:" .. resourceName then
			printIfStateChanged(errorState, function()
				print("^1[^6DankLife Gaming ^2- ^0No version found for " .. resourceName .. " in scripts_version.json.^0")
				print("^1[^6DankLife Gaming ^2- ^0Please rename your resource to '" ..
					config.originalScriptName .. "' to keep using DankLife Gaming's Custom Version Checker.^0")
			end)
			return
		end

		if errorState == "decode_failed" then
			printIfStateChanged(errorState, function()
				print("^1[^6DankLife Gaming ^2- ^0Failed to decode JSON.^0")
			end)
			return
		end

		if errorState and errorState:find("^fetch_failed:") then
			printIfStateChanged(errorState, function()
				print("^1[^6DankLife Gaming ^2- ^0Failed to fetch scripts_version.json after " ..
					config.maxRetries .. " attempts.^0")
			end)
			if cachedRemoteVersion then
				reportComparison(resourceName, curVer, cachedRemoteVersion)
			end
			return
		end

		reportComparison(resourceName, curVer, remoteVersion)
	end)
end

CreateThread(function()
	CheckForUpdates()
end)

-- Schedule update checks using ox_lib cron.
lib.cron.new(config.cronExpression, function(task, date)
	CheckForUpdates()
end, { debug = false })

local runner = {}

local passed = 0
local failed = 0
local skipped = 0

function runner.test(name: string, fn: () -> ...any)
	local ok, err = xpcall(fn, debug.traceback)
	if ok then
		passed += 1
		print(`  [pass] {name}`)
	else
		failed += 1
		print(`  [FAIL] {name}`)
		print(`         {tostring(err)}`)
	end
end

function runner.skip(name: string, reason: string)
	skipped += 1
	print(`  [skip] {name} -- {reason}`)
end

function runner.summary(): (number, number, number)
	return passed, failed, skipped
end

return runner

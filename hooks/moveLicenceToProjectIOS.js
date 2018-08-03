module.exports = function(ctx) {
	if (ctx.opts.platforms && ctx.opts.platforms.indexOf('ios') < 0) {
		return;
	}

	// WIP;
	return;

	const childProcess = ctx.requireCordovaModule('child_process');
	return childProcess.exec(`cp -r ./libs/smartengine/ ./platforms/ios/`, function(error) {
		if (error) {
			console.log(
				`[SmartIDReaderPlugin] error while move licence to ios project: ${error.message ||
					error}`
			);
		}
	});
};

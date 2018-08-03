module.exports = function(ctx) {
	if (ctx.opts.platforms && ctx.opts.platforms.indexOf('android') < 0) {
		return;
	}

	const childProcess = ctx.requireCordovaModule('child_process');
	return childProcess.exec(
		`cp -r ./libs/smartengine/ ./platforms/android/app/src/main/assets/data`,
		function(error) {
			if (error) {
				console.log(
					`[SmartIDReaderPlugin] error while move licence to android project: ${error.message ||
						error}`
				);
			}
		}
	);
};

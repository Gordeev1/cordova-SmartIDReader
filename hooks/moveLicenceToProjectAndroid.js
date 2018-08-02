module.exports = function(ctx) {
	if (ctx.opts.platforms && ctx.opts.platforms.indexOf('android') < 0) {
		return;
	}

	var childProcess = ctx.requireCordovaModule('child_process');
	return childProcess.exec(
		`cp -r ./libs/smartengine/ ./platforms/android/app/src/main/assets/data`,
		function(error) {
			if (error) {
				throw new Error(
					`[cordova-SmartIDReader] error while move licence to project: ${error.message ||
						error}`
				);
			}
		}
	);
};

var exec = require('cordova/exec');

var SmartIDReader = {
	recognize: function (mask, timeout) {
		return new Promise(function (resolve, reject) {
			return exec(
				function (result) { return resolve(cordova.platformId === 'android' ? JSON.parse(result) : result) },
				reject,
				'SmartIDReader',
				'recognize',
				[mask, timeout].filter(function (item) { return item })
			)
		})
	}
};

module.exports = SmartIDReader;

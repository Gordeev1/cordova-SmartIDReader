const PLUGIN_NAME = '[SmartIDReaderPlugin]';
const headerPathsUpdate = '"$(PROJECT_NAME)/Resources"';
const langStandartUpdate = 'CLANG_CXX_LANGUAGE_STANDARD = gnu++0x';
const langLibraryUpdate = 'CLANG_CXX_LIBRARY = libc++';

module.exports = function(ctx) {
	if (ctx.opts.platforms && ctx.opts.platforms.indexOf('ios') < 0) {
		return;
	}

	var fs = ctx.requireCordovaModule('fs');
	var path = ctx.requireCordovaModule('path');
	var os = ctx.requireCordovaModule('os');

	function updateConfig(data, update) {
		return data + os.EOL + update;
	}

	const xcConfigBuildFilePath = path.join(
		ctx.opts.projectRoot,
		'platforms/ios/cordova/build.xcconfig'
	);

	try {
		if (!fs.existsSync(xcConfigBuildFilePath)) {
			return console.log(
				`${SmartIDReaderPlugin} build.xcconfig not found, you will need to set HEADER_SEARCH_PATHS manually`
			);
		}

		let data = fs.readFileSync(xcConfigBuildFilePath, 'utf8');
		let updatesCount = 0;

		if (!data.includes(headerPathsUpdate)) {
			data = updateHeaderPaths(data);
			updatesCount += 1;
		}
		if (!data.includes(langStandartUpdate)) {
			data = updateConfig(data, langStandartUpdate);
			updatesCount += 1;
		}
		if (!data.includes(langLibraryUpdate)) {
			data = updateConfig(data, langLibraryUpdate);
			updatesCount += 1;
		}

		if (updatesCount === 0) {
			return;
		}

		return fs.writeFileSync(xcConfigBuildFilePath, data, 'utf8');
	} catch (error) {
		console.log(
			'Unable to update build.xcconfig file, you will need to configure your Xcode project manualy' +
				error.message || error
		);
	}
};

function updateHeaderPaths(data) {
	let result = data.split('\n');

	const lineIndex = result.findIndex(line => line.includes('HEADER_SEARCH_PATHS'));

	if (lineIndex < 0) {
		const newLine = `HEADER_SEARCH_PATHS = ${headerPathsUpdate}`;
		result = [...result, newLine];
	} else {
		const updatedLine = `${result[lineIndex]} ${headerPathsUpdate}`;
		result = [...result.slice(0, lineIndex), updatedLine, ...result.slice(lineIndex + 1)];
	}

	return result.join('\n');
}

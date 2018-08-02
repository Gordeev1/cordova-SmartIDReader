interface Window {
	SmartIDReaderPlugin: SmartIDReaderPlugin;
}

type RecognizedField = {
	isAccepted: boolean;
	value: string;
};

// TODO: validate keys
type RecognizeResponse = { [key: string]: RecognizedField };

interface SmartIDReaderPlugin {
	recognize: (
		mask?: string = 'ru.passport.*',
		timeout?: string = '5.0'
	) => Promise<RecognizeResponse>;
}

declare var SmartIDReaderPlugin: SmartIDReaderPlugin;

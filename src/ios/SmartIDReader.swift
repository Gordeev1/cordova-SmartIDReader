@objc(SmartIDReader) class SmartIDReader : CDVPlugin, SmartIDViewControllerDelegate {

    var lastCommand: CDVInvokedUrlCommand?

    func recognize(_ command: CDVInvokedUrlCommand) {

        let mask = command.arguments[0];
        let timeout = command.arguments[1];
        self.lastCommand = command;

        let smartIDController: SmartIDViewControllerSwift = SmartIDViewControllerSwift()
        // smartIDController.sessionTimeout = 5.0;
        smartIDController.displayZonesQuadrangles = true
        smartIDController.displayDocumentQuadrangle = true
        smartIDController.addEnabledDocTypesMask(mask as! String)
        smartIDController.smartIDDelegate = self

        self.viewController?.present(
            smartIDController, 
            animated: true, 
            completion: nil
        )
    }

    func smartIDViewControllerDidRecognize(_ result: SmartIDRecognitionResult!) {
        
        if (self.lastCommand != nil) {
            var pluginResultContent: Dictionary<String, Dictionary<String, Any>> = [:];
            
            for (key, value) in result.getStringFields() {
                let content: Dictionary<String, Any> = ["value": value, "isAccepted": result.isStringFieldAccepted(key)];
                pluginResultContent[key] = content;
            }
            
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: pluginResultContent
            )
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: self.lastCommand?.callbackId
            )
            self.lastCommand = nil
            
            self.viewController.dismiss(animated: true, completion: nil)
        }
        
    }

    func smartIDviewControllerDidCancel() {
        if (self.lastCommand != nil) {
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK
            )
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: self.lastCommand?.callbackId
            )
            self.lastCommand = nil
            
            self.viewController.dismiss(animated: true, completion: nil)
        }
    }

}

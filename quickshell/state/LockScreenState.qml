pragma Singleton
import Quickshell.Io
import Quickshell
import Quickshell.Services.Pam
import QtQuick

Singleton {
    id: root

    property bool locked: false
    property bool authenticating: pam.active
    property bool authFailed: false

    // Quickshell's built-in PAM integration
    PamContext {
        id: pam
        config: "login" // Uses /etc/pam.d/login for authentication

        onCompleted: (result) => {
            if (result === PamResult.Success) {
                root.unlock()
            } else {
                root.authFailed = true
            }
        }

        onError: (error) => {
            root.authFailed = true
        }

        // Handles standard password requests from PAM
        onPamMessage: {
            if (pam.responseRequired) {
                // If PAM asks for a password, supply our stored attempt
                pam.respond(root.pendingPassword)
                root.pendingPassword = ""
            }
        }
    }

    property string pendingPassword: ""

    function lock() {
        if (root.locked) return
        authFailed = false
        root.locked = true
    }

    function unlock() {
        authFailed = false
        root.locked = false
    }

    function authenticate(password) {
        if (pam.active) return
        
        authFailed = false
        pendingPassword = password
        
        // Start PAM authentication
        pam.start()
    }

    IpcHandler {
        target: "lockscreen"

        function lock(): void { root.lock() }
        function isLocked(): bool { return root.locked }
    }
}

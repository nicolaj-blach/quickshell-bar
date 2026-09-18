pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Niri IPC singleton for workspace and window tracking
Singleton {
    id: niri

    // Workspace state
    property var workspaces: []  // Array of {id, output, name, isActive, isFocused}
    property int focusedWorkspaceId: -1
    property string focusedOutput: ""

    // Window state for occupied detection
    property var windows: []  // Array of {id, workspaceId, ...}

    readonly property string socketPath: Quickshell.env("NIRI_SOCKET") ?? ""

    // Event stream process using niri msg event-stream
    Process {
        id: eventStreamProc
        command: ["niri", "msg", "event-stream"]
        running: niri.socketPath !== ""

        stdout: SplitParser {
            onRead: function(data) {
                if (data.trim()) {
                    try {
                        var event = JSON.parse(data)
                        niri.handleEvent(event)
                    } catch (e) {
                        console.error("Failed to parse niri event:", e, data)
                    }
                }
            }
        }
    }

    function handleEvent(event) {
        if (event.WorkspacesChanged) {
            updateWorkspaces(event.WorkspacesChanged.workspaces)
        } else if (event.WorkspaceActivated) {
            var wsEvent = event.WorkspaceActivated
            markWorkspaceActive(wsEvent.id, wsEvent.focused)
        } else if (event.WorkspaceFocused) {
            focusedWorkspaceId = event.WorkspaceFocused.id
        } else if (event.WindowsChanged) {
            windows = event.WindowsChanged.windows || []
        } else if (event.WindowOpenedOrChanged) {
            updateWindow(event.WindowOpenedOrChanged.window)
        } else if (event.WindowClosed) {
            removeWindow(event.WindowClosed.id)
        } else if (event.WindowFocusChanged) {
            if (event.WindowFocusChanged.id) {
                var win = findWindow(event.WindowFocusChanged.id)
                if (win) {
                    var ws = findWorkspace(win.workspace_id)
                    if (ws) focusedOutput = ws.output
                }
            }
        }
    }

    function findWindow(id) {
        for (var i = 0; i < windows.length; i++) {
            if (windows[i].id === id) return windows[i]
        }
        return null
    }

    function findWorkspace(id) {
        for (var i = 0; i < workspaces.length; i++) {
            if (workspaces[i].id === id) return workspaces[i]
        }
        return null
    }

    function updateWorkspaces(wsData) {
        var newWorkspaces = []
        for (var i = 0; i < wsData.length; i++) {
            var ws = wsData[i]
            newWorkspaces.push({
                id: ws.id,
                idx: ws.idx,
                output: ws.output,
                name: ws.name || "",
                isActive: ws.is_active || false,
                isFocused: ws.is_focused || false
            })
        }
        workspaces = newWorkspaces

        // Find focused workspace
        for (var j = 0; j < workspaces.length; j++) {
            if (workspaces[j].isFocused) {
                focusedWorkspaceId = workspaces[j].id
                focusedOutput = workspaces[j].output
                break
            }
        }
    }

    function markWorkspaceActive(id, focused) {
        var targetOutput = ""
        var targetWs = findWorkspace(id)
        if (targetWs) targetOutput = targetWs.output

        var newWorkspaces = []
        for (var i = 0; i < workspaces.length; i++) {
            var ws = workspaces[i]
            var newWs = {
                id: ws.id,
                idx: ws.idx,
                output: ws.output,
                name: ws.name,
                isActive: ws.isActive,
                isFocused: ws.isFocused
            }

            if (ws.id === id) {
                newWs.isActive = true
                newWs.isFocused = focused
            } else if (ws.output === targetOutput) {
                newWs.isActive = false
                if (focused) newWs.isFocused = false
            } else if (focused) {
                newWs.isFocused = false
            }

            newWorkspaces.push(newWs)
        }
        workspaces = newWorkspaces

        if (focused) {
            focusedWorkspaceId = id
            if (targetWs) focusedOutput = targetWs.output
        }
    }

    function updateWindow(win) {
        var newWindows = []
        var found = false
        for (var i = 0; i < windows.length; i++) {
            if (windows[i].id === win.id) {
                newWindows.push(win)
                found = true
            } else {
                newWindows.push(windows[i])
            }
        }
        if (!found) {
            newWindows.push(win)
        }
        windows = newWindows
    }

    function removeWindow(id) {
        var newWindows = []
        for (var i = 0; i < windows.length; i++) {
            if (windows[i].id !== id) {
                newWindows.push(windows[i])
            }
        }
        windows = newWindows
    }

    // Check if workspace has windows
    function isOccupied(workspaceId) {
        for (var i = 0; i < windows.length; i++) {
            if (windows[i].workspace_id === workspaceId) return true
        }
        return false
    }

    // Get workspaces for a specific output
    function getWorkspacesForOutput(output) {
        var result = []
        for (var i = 0; i < workspaces.length; i++) {
            if (workspaces[i].output === output) {
                result.push(workspaces[i])
            }
        }
        result.sort(function(a, b) { return a.idx - b.idx })
        return result
    }

    // Focus a workspace by ID
    function focusWorkspace(id) {
        if (socketPath === "") return
        focusProc.wsId = id
        focusProc.running = true
    }

    Process {
        id: focusProc
        property int wsId: 0
        command: ["niri", "msg", "action", "focus-workspace", wsId.toString()]
        running: false
    }

    // Initial fetch processes
    Process {
        id: initWorkspacesProc
        command: ["niri", "msg", "-j", "workspaces"]
        running: false
        stdout: SplitParser {
            onRead: function(data) {
                try {
                    var wsData = JSON.parse(data)
                    niri.updateWorkspaces(wsData)
                } catch (e) {
                    console.error("Failed to parse initial workspaces:", e)
                }
            }
        }
    }

    Process {
        id: initWindowsProc
        command: ["niri", "msg", "-j", "windows"]
        running: false
        stdout: SplitParser {
            onRead: function(data) {
                try {
                    niri.windows = JSON.parse(data) || []
                } catch (e) {
                    console.error("Failed to parse initial windows:", e)
                }
            }
        }
    }

    Component.onCompleted: {
        if (socketPath === "") {
            console.warn("NIRI_SOCKET not set, workspaces won't work")
            return
        }
        initWorkspacesProc.running = true
        initWindowsProc.running = true
    }
}

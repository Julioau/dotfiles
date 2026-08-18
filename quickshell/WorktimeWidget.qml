import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs

Rectangle {
    id: worktimeRect
    property string globalFont: "SpaceMono Nerd Font Propo"
    property string currentDateStr: Qt.formatDate(new Date(), "yyyy-MM-dd")
    
    // Limits
    property int limitMinutes: 360 // 6 hours
    
    // State
    property double loginTime: 0
    property int worktimeMinutes: 0
    
    color: worktimeMinutes >= limitMinutes ? Theme.red : Theme.background
    radius: 10
    
    // Width adjusting to content
    height: 36
    width: worktimeText.implicitWidth + 30
    
    JsonAdapter {
        id: jsonAdapter
        property string date: ""
        property double login_time: 0
    }

    FileView {
        id: cacheFile
        path: Quickshell.cachePath("worktime.json")
        adapter: jsonAdapter
        
        onLoaded: {
            if (jsonAdapter.date === worktimeRect.currentDateStr && jsonAdapter.login_time) {
                worktimeRect.loginTime = jsonAdapter.login_time;
            } else {
                // Not found or different date -> start from now today
                worktimeRect.loginTime = new Date().getTime();
                saveState();
            }
            updateMinutes();
        }
        
        onLoadFailed: {
            // File doesn't exist, create it natively
            worktimeRect.loginTime = new Date().getTime();
            saveState();
            updateMinutes();
        }
        
        // Block during startup to fetch history if available
        blockLoading: true
    }

    function saveState() {
        jsonAdapter.date = worktimeRect.currentDateStr;
        jsonAdapter.login_time = worktimeRect.loginTime;
        cacheFile.writeAdapter();
    }
    
    function updateMinutes() {
        if (worktimeRect.loginTime === 0) return;
        var now = new Date();
        var newDateStr = Qt.formatDate(now, "yyyy-MM-dd");
        
        if (newDateStr !== worktimeRect.currentDateStr) {
            // Day rolled over, reset to now
            worktimeRect.currentDateStr = newDateStr;
            worktimeRect.loginTime = now.getTime();
            saveState();
        }
        
        var totalMinutes = Math.floor((now.getTime() - worktimeRect.loginTime) / 60000);
        
        // Subtract 60 minutes if you logged in before 12:00 PM and it's currently 13:00 PM or later
        var loginDate = new Date(worktimeRect.loginTime);
        if (loginDate.getHours() < 12 && totalMinutes >= 60 && now.getHours() >= 13) {
             totalMinutes -= 60;
        }

        worktimeRect.worktimeMinutes = totalMinutes;
    }

    Timer {
        id: workTimer
        interval: 60000 // 1 minute
        running: true
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            updateMinutes();
        }
    }

    Text {
        id: worktimeText
        anchors.centerIn: parent
        font.family: worktimeRect.globalFont
        
        // Turn text background colored if exceeding the limit (6h)
        color: worktimeRect.worktimeMinutes >= worktimeRect.limitMinutes ? Theme.background : Theme.text
        
        text: {
            var h = Math.floor(worktimeRect.worktimeMinutes / 60);
            var m = worktimeRect.worktimeMinutes % 60;
            return "󰔟 " + h + "h " + m + "m";
        }
    }
}

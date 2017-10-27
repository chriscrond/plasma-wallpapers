import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.taskmanager 0.1 as TaskManager

Item {
	property alias screenGeometry: tasksModel.screenGeometry
	property bool noWindowActive: true

	TaskManager.VirtualDesktopInfo { id: virtualDesktopInfo }
	TaskManager.ActivityInfo { id: activityInfo }
	TaskManager.TasksModel {
		id: tasksModel
		sortMode: TaskManager.TasksModel.SortVirtualDesktop
		groupMode: TaskManager.TasksModel.GroupDisabled

		activity: activityInfo.currentActivity
		virtualDesktop: virtualDesktopInfo.currentDesktop
		screenGeometry: wallpaper.screenGeometry

		filterByActivity: true
		filterByVirtualDesktop: true
		filterByScreen: true

		onActiveTaskChanged: {
			activeWindowModel.sourceModel = tasksModel
			updateActiveWindowInfo()
		}
		onDataChanged: {
			updateActiveWindowInfo()
		}
	}
	PlasmaCore.SortFilterModel {
		id: activeWindowModel
		filterRole: 'IsActive'
		filterRegExp: 'true'
		sourceModel: tasksModel
		onDataChanged: updateActiveWindowInfo()
	}


	function activeTask() {
		return activeWindowModel.get(0) || {}
	}

	function updateActiveWindowInfo() {
		var actTask = activeTask()
		noWindowActive = activeWindowModel.count === 0 || actTask.IsActive !== true
		currentWindowMaximized = !noWindowActive && actTask.IsMaximized === true
		isActiveWindowPinned = actTask.VirtualDesktop === -1;
		if (noWindowActive) {
			windowTitleText.text = plasmoid.configuration.noWindowText
			iconItem.source = plasmoid.configuration.noWindowIcon
		} else {
			windowTitleText.text = textType === 1 ? actTask.AppName : replaceTitle(actTask.display)
			iconItem.source = actTask.decoration
		}
	}
}
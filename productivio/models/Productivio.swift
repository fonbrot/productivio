//
//  Productivio.swift
//  productivio
//

import Foundation
import UIKit
import AudioToolbox

private enum Constans {
    static let workTime:Int = 25
    static let shortBreakTime: Int = 5
    static let longBreakTime: Int = 15
    static let longBreakAfter: Int = 4
    static let soundID: SystemSoundID = 1022
    static let playSound = true
    static let screenOn = false
    static let autoStart = false
}

private enum SettingsKeys {
    static let workTime = "Productivio.workTime"
    static let shortBreakTime = "Productivio.shortBreakTime"
    static let longBreakTime = "Productivio.longBreakTime"
    static let longBreakAfter = "Productivio.longBreakAfter"
    static let soundID = "Productivio.soundID"
    static let playSound = "Productivio.playSound"
    static let screenOn = "Productivio.screenOn"
    static let autoStart = "Productivio.autoStart"
    static let currentDate = "Productivio.currentDate"
    static let todayCount = "Productivio.todayCount"
    static let allCount = "Productivio.allCount"
    static let stopTimerDate = "Productivio.stopTimerDate"
    static let currentWork = "Productivio.currentWork"
    static let currentTask = "Productivio.currentTask"
}

enum State {
    case work, shortBreak, longBreak
}

enum UISettings {
    static let timerFontSize: CGFloat = 110
    
    static let redColor = UIColor.red
    static let lightRedColor = UIColor(red: 1, green: 208 / 255, blue: 199 / 255, alpha: 1)
    static let greenColor = UIColor.green
    static let lightGreenColor = UIColor(red: 214 / 255, green: 1, blue: 231 / 255, alpha: 1)
}

enum PickerData {
    static let timeData = [5,10,15,20,25,30,35,40,45,50,60]
    static let numData = [1,2,3,4,5,6,7,8,9,10]
    static let soundIDs: [SystemSoundID] = [1021, 1022, 1023, 1025,1026]
    static let soundTitles = ["Bloom", "Calypso", "ChooChoo", "Fanfare", "Ladder"]
}

class Productivio {
    static let shared = Productivio()
    private init() {}
    
    private var userDefaults = UserDefaults.standard
    
    //MARK: Settings
    
    var workTime: Int {
        get { return (userDefaults.object(forKey: SettingsKeys.workTime) as? Int ?? Constans.workTime) * 60 }
        set { userDefaults.set(newValue, forKey: SettingsKeys.workTime) }
    }
    
    var shortBreakTime: Int {
        get { return (userDefaults.object(forKey: SettingsKeys.shortBreakTime) as? Int ?? Constans.shortBreakTime) * 60 }
        set { userDefaults.set(newValue, forKey: SettingsKeys.shortBreakTime) }
    }
    
    var longBreakTime: Int {
        get { return (userDefaults.object(forKey: SettingsKeys.longBreakTime) as? Int ?? Constans.longBreakTime) * 60 }
        set { userDefaults.set(newValue, forKey: SettingsKeys.longBreakTime) }
    }
    
    var longBreakAfter: Int {
        get { return userDefaults.object(forKey: SettingsKeys.longBreakAfter) as? Int ?? Constans.longBreakAfter }
        set { userDefaults.set(newValue, forKey: SettingsKeys.longBreakAfter) }
    }
    
    var soundID: SystemSoundID {
        get { return userDefaults.object(forKey: SettingsKeys.soundID) as? SystemSoundID ?? Constans.soundID }
        set { userDefaults.set(newValue, forKey: SettingsKeys.soundID) }
    }
    
    var playSound: Bool {
        get { return userDefaults.object(forKey: SettingsKeys.playSound) as? Bool ?? Constans.playSound }
        set { userDefaults.set(newValue, forKey: SettingsKeys.playSound) }
    }
    
    var screenOn: Bool {
        get { return userDefaults.object(forKey: SettingsKeys.screenOn) as? Bool ?? Constans.screenOn }
        set { userDefaults.set(newValue, forKey: SettingsKeys.screenOn) }
    }
    
    var autoStart: Bool {
        get { return userDefaults.object(forKey: SettingsKeys.autoStart) as? Bool ?? Constans.autoStart }
        set { userDefaults.set(newValue, forKey: SettingsKeys.autoStart) }
    }
    
    var todayCount: Int {
        get { return userDefaults.object(forKey: SettingsKeys.todayCount) as? Int ?? 0 }
        set {
            userDefaults.set(newValue, forKey: SettingsKeys.todayCount)
            allCount += 1
        }
    }
    
    var allCount: Int {
        get { return userDefaults.object(forKey: SettingsKeys.allCount) as? Int ?? 0 }
        set { userDefaults.set(newValue, forKey: SettingsKeys.allCount) }
    }
    
    var stopTimerDate: Date? {
        get { return userDefaults.object(forKey: SettingsKeys.stopTimerDate) as? Date }
        set {
            if let value = newValue {
                userDefaults.set(value, forKey: SettingsKeys.stopTimerDate)
            } else {
                userDefaults.removeObject(forKey: SettingsKeys.stopTimerDate)
            }
        }
    }
    
    var currentWork: Bool {
        get { return userDefaults.object(forKey: SettingsKeys.currentWork) as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: SettingsKeys.currentWork) }
    }
    
    private var currentDate: String {
        get { return userDefaults.object(forKey: SettingsKeys.currentDate) as? String ?? "" }
        set { userDefaults.set(newValue, forKey: SettingsKeys.currentDate) }
    }
    
    var currentTask: String {
        get { return userDefaults.object(forKey: SettingsKeys.currentTask) as? String ?? "" }
        set { userDefaults.set(newValue.prefix(100), forKey: SettingsKeys.currentTask) }
    }
    
    //MARK: Functions
    
    func getTodayCount() -> Int {
        let date = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: date)
        if currentDate == dateString {
            return todayCount
        } else {
            currentDate = dateString
            todayCount = 0
            return 0
        }
    }
    
    func resetCounts() {
        todayCount = 0
        allCount = 0
    }
}

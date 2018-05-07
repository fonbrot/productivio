//
//  ViewController.swift
//  productivio
//

import UIKit
import AudioToolbox
import UserNotifications

class ViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var todayCountLabel: UILabel!
    
    private var productivio = Productivio.shared
    
    private var timer: Timer?
    
    private var timerButtonImage: UIImage?
    
    private var running = false {
        didSet {
            if productivio.screenOn {
                UIApplication.shared.isIdleTimerDisabled = running
            }
        }
    }
    
    private var longBreak: Bool {
        return productivio.todayCount > 0 && productivio.todayCount % 4 == 0
    }
    
    private var timeLeft: Int = 0
    
    private let center = UNUserNotificationCenter.current()
   
    //MARK: Actions
    
    @IBAction func startTapped(_ sender: UIButton) {
        if running {
            cancelTimer()
        } else {
            startTimer()
        }
        setUI()
    }
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        configureUI()
        
        resumeTimer()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    //MARK: Functions
    
    @objc func willEnterForeground() {
        resumeTimer()
        setUI()
    }
    
    @objc func didEnterBackground() {
        stopTimer()
    }
    
    //MARK: Interval
    
    private func completeInterval() {
        if productivio.currentWork {
            completeWork()
        } else {
            completeBreak()
        }
    }
    
    private func completeWork() {
        productivio.todayCount = productivio.getTodayCount() + 1
        productivio.currentWork = false
    }
    
    private func completeBreak() {
        productivio.currentWork = true
    }
    
    //MARK: Timer
    
    private func startTimer() {
        removeOldNotification()
        cancelNotification()
        runTimer()
        createNotification()
    }
    
    private func cancelTimer() {
        cancelNotification()
        removeOldNotification()
        stopTimer()
        productivio.currentWork = true
        resetTimeLeft()
        setUI()
    }
    
    private func resumeTimer() {
        if let stopTime = productivio.stopTimerDate {
            let newTime = stopTime.timeIntervalSinceNow
            if newTime > 0 {
                timeLeft = Int(newTime)
                startTimer()
            } else {
                stopTimer()
                removeOldNotification()
                cancelNotification()
                completeInterval()
                resetTimeLeft()
            }
        } else {
            stopTimer()
            resetTimeLeft()
        }
    }
    
    private func completeTimer() {
        stopTimer()
        productivio.stopTimerDate = nil
        
        if productivio.playSound {
            playSound()
        }
        
        completeInterval()
        resetTimeLeft()
        
        if !productivio.currentWork || productivio.autoStart {
            startTimer()
        }
        setUI()
    }
    
    private func updateTimer() {
        timeLeft = timeLeft - 1
        setTimerLabel()
        if timeLeft > 0 {
        } else {
            completeTimer()
        }
    }
    
    private func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            self.updateTimer()
        }
        running = true
    }
    
    private func stopTimer() {
        timer?.invalidate()
        running = false
    }
    
    //MARK: Reset
    
     private func resetTimeLeft() {
        if productivio.currentWork {
            timeLeft = productivio.workTime
        } else if longBreak {
            timeLeft = productivio.longBreakTime
        } else {
         timeLeft = productivio.shortBreakTime
        }
    }
    
    //MARK: set UI
    
    private func setUI() {
        setTimerButton()
        setUIColor()
        setTimerLabel()
        setTodayCountLabel()
    }
    
    private func setTimerLabel() {
        timerLabel.text = String(format: "%02d:%02d", timeLeft / 60, timeLeft % 60)
        progressView.setProgress(Float(timeLeft) / Float(productivio.workTime), animated: false)
    }

    private func setTimerButton() {
        if running {
            timerButtonImage = UIImage(named: "stop")?.withRenderingMode(.alwaysTemplate)
        } else {
            timerButtonImage = UIImage(named: "play")?.withRenderingMode(.alwaysTemplate)
        }
        timerButton.setImage(timerButtonImage, for: .normal)
    }
    
    private func setUIColor() {
        if productivio.currentWork {
            timerLabel.textColor = UISettings.redColor
            progressView.tintColor = UISettings.redColor
            progressView.backgroundColor = UISettings.lightRedColor
            timerButton.layer.backgroundColor = UISettings.redColor.cgColor
        } else {
            timerLabel.textColor = UISettings.greenColor
            progressView.tintColor = UISettings.greenColor
            progressView.backgroundColor = UISettings.lightGreenColor
            timerButton.layer.backgroundColor = UISettings.greenColor.cgColor
        }
    }
    
    private func playSound() {
        AudioServicesPlaySystemSound(productivio.soundID)
    }
    
    private func setTodayCountLabel() {
        todayCountLabel.text = "\(productivio.getTodayCount())"
    }
    
    private func configureUI() {
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UISettings.timerFontSize, weight: .ultraLight)
        timerButton.layer.cornerRadius = timerButton.frame.width / 2
        taskTextField.text = productivio.currentTask
    }
    
    //MARK: Notifications
    
    private func createNotification() {
        var title: String
        var body: String
        
        if productivio.currentWork {
            title = NSLocalizedString("Work finished", comment: "")
            body = NSLocalizedString("Time to take a break", comment: "")
        } else {
            title = NSLocalizedString("Break finished", comment: "")
            body = NSLocalizedString("Time to get back to work", comment: "")
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(timeLeft), repeats: false)
        
        let request = UNNotificationRequest(identifier: "Productivio", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
        
        productivio.stopTimerDate = Date(timeIntervalSinceNow: Double(timeLeft))
    }
    
    private func removeOldNotification() {
        center.removeAllDeliveredNotifications()
    }
    
    private func cancelNotification() {
        center.removeAllPendingNotificationRequests()
        productivio.stopTimerDate = nil
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        productivio.currentTask = textField.text ?? ""
    }
}

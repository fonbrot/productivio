//
//  SettingsViewController.swift
//  productivio
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var workText: UITextField!
    @IBOutlet weak var shortText: UITextField!
    @IBOutlet weak var longText: UITextField!
    @IBOutlet weak var longAfterText: UITextField!
    
    @IBOutlet weak var playSoundSwitch: UISwitch!
    @IBOutlet weak var toneLabel: UILabel!
    @IBOutlet weak var screenOnSwitch: UISwitch!
    @IBOutlet weak var autoStartSwitch: UISwitch!
    
    private var timePicker: UIPickerView!
    private var numPicker: UIPickerView!
    private var currentTextField: UITextField?
    
    private var productivio = Productivio.shared
    
    @IBAction func playSoundChange(_ sender: UISwitch) {
        productivio.playSound = sender.isOn
    }
    
    @IBAction func screenOnCanged(_ sender: UISwitch) {
        productivio.screenOn = sender.isOn
    }
    
    @IBAction func autoStartCnanged(_ sender: UISwitch) {
        productivio.autoStart = sender.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workText.text = "\(productivio.workTime / 60)"
        shortText.text = "\(productivio.shortBreakTime / 60)"
        longText.text = "\(productivio.longBreakTime / 60)"
        longAfterText.text = "\(productivio.longBreakAfter)"
        
        timePicker = UIPickerView()
        timePicker.tag = 1
        timePicker.delegate = self
        
        numPicker = UIPickerView()
        numPicker.tag = 2
        numPicker.delegate = self
        
        playSoundSwitch.isOn = productivio.playSound
        screenOnSwitch.isOn = productivio.screenOn
        autoStartSwitch.isOn = productivio.autoStart
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setToneLabel()
    }
    
    private func addPicker(_ textField: UITextField) {
        if textField == longAfterText {
            textField.inputView = numPicker
            if let currentText = Int(textField.text!), let row = PickerData.numData.index(of: currentText) {
                numPicker.selectRow(row, inComponent: 0, animated: true)
            }
        } else {
            textField.inputView = timePicker
            if let currentText = Int(textField.text!), let row = PickerData.timeData.index(of: currentText) {
                timePicker.selectRow(row, inComponent: 0, animated: true)
            }
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClick))
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let label = UILabel()
        label.text = titleForPicker(textField)
        let titleButton = UIBarButtonItem(customView: label)
        toolbar.setItems([leftSpace, titleButton, rightSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
    
    @objc func doneClick() {
        currentTextField?.resignFirstResponder()
    }
    
    private func titleForPicker(_ textField: UITextField) -> String {
        switch textField {
        case workText:
            return NSLocalizedString("Work duration", comment: "")
        case shortText:
            return NSLocalizedString("Short break duration", comment: "")
        case longText:
            return NSLocalizedString("Long break duration", comment: "")
        case longAfterText:
            return NSLocalizedString("Long break after", comment: "")
        default:
            return ""
        }
    }
    
    private func setToneLabel() {
        if let index = PickerData.soundIDs.index(of: productivio.soundID) {
            toneLabel.text = PickerData.soundTitles[index]
        }
    }
}

extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return PickerData.timeData.count
        case 2:
            return PickerData.numData.count
        default:
            print("unexpected pickerview")
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return String(PickerData.timeData[row])
        case 2:
            return String(PickerData.numData[row])
        default:
            print("unexpected pickerview")
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            currentTextField?.text = "\(PickerData.timeData[row])"
        case 2:
            currentTextField?.text = "\(PickerData.numData[row])"
        default:
            print("unexpected pickerview")
        }
    }
    
    private func saveSelectedValue(_ textField: UITextField) {
        switch textField {
        case workText:
            if let value = Int(textField.text!) {
                productivio.workTime = value
            }
        case shortText:
            if let value = Int(textField.text!) {
                productivio.shortBreakTime = value
            }
        case longText:
            if let value = Int(textField.text!) {
                productivio.longBreakTime = value
            }
        case longAfterText:
            if let value = Int(textField.text!) {
                productivio.longBreakAfter = value
            }
        default:
            print("unexpected textField")
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        addPicker(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveSelectedValue(textField)
        currentTextField = nil
    }
}

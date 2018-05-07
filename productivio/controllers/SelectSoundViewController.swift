//
//  SelectSoundViewController.swift
//  productivio
//

import UIKit

private enum CellIdentifiers {
    static let soundCell = "soundCell"
}

class SelectSoundViewController: UITableViewController {

    private var productivio = Productivio.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tone"
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PickerData.soundTitles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.soundCell, for: indexPath)
        cell.textLabel?.text = PickerData.soundTitles[indexPath.row]
        
        cell.accessoryType = .none
        if PickerData.soundIDs[indexPath.row] == productivio.soundID {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        productivio.soundID = PickerData.soundIDs[indexPath.row]
        tableView.reloadData()
    }
}

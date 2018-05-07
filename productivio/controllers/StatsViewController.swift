//
//  StatsViewController.swift
//  productivio
//

import UIKit

class StatsViewController: UITableViewController {
    
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var alltimeLabel: UILabel!
    
    private var productivio = Productivio.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabel()
    }
    
    private func updateLabel() {
        todayLabel.text = "\(productivio.todayCount)"
        alltimeLabel.text = "\(productivio.allCount)"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [1, 0] {
            productivio.resetCounts()
            updateLabel()
        }
    }
}

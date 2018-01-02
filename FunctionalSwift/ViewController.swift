//
//  ViewController.swift
//  FunctionalSwift
//
//  Created by Abj on 2017/12/25.
//  Copyright © 2017年 Abj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let dataSource = ["函数式思想", "案例研究: 封装Core Image", "Map、Filter和Reduce"]
    let identify = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identify)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identify)
        }

        cell?.textLabel?.text = dataSource[indexPath.row]
        return cell!
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            // FunctionalThinkingController
            break
        case 1:
            navigationController?.pushViewController(CoreImagePackageController(), animated: true)
        case 2:
            navigationController?.pushViewController(MapFilterReduceController(), animated: true)
        default:
            break
        }
        
    }
}

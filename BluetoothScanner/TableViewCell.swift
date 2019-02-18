//
//  TableViewCell.swift
//  BluetoothScanner
//
//  Created by Сергей Вихляев on 14/02/2019.
//  Copyright © 2019 Сергей Вихляев. All rights reserved.
//

import UIKit
import CoreBluetooth

class TableViewCell: UITableViewCell {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!

    var inputPeripheral: CBPeripheral? {
        didSet {
            deviceNameLabel.text = inputPeripheral?.name
            uuidLabel.text = inputPeripheral?.identifier.uuidString
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        deviceNameLabel.text = ""
        uuidLabel.text = ""
        inputPeripheral = nil
    }

}

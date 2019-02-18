//
//  MyTableViewController.swift
//  BluetoothScanner
//
//  Created by Сергей Вихляев on 28/01/2019.
//  Copyright © 2019 Сергей Вихляев. All rights reserved.
//

import UIKit
import CoreBluetooth

class MyTableViewController: UITableViewController {

    enum ScanInfo: String {
        case alreadyScan = "Сканируется в данный момент"
        case bluetoothOff = "Bluetooth недоступен"
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var currentStatusLabel: UILabel!

    var foundedPeritherals: [CBPeripheral] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var isScanning = false {
        didSet {
            if isScanning {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()

            }
        }
    }

    @IBAction func scanButtonWasPressed(_ sender: UIBarButtonItem) {
        if centralManager.isScanning {
            centralManager.stopScan()
            isScanning = centralManager.isScanning
            sender.title = "Scan"
        } else if centralManager.state != .poweredOn && !centralManager.isScanning {
            showAlert(.bluetoothOff)
            isScanning = centralManager.isScanning
        } else if centralManager.state == .poweredOn && !centralManager.isScanning {
            foundedPeritherals.removeAll()
            tableView.reloadData()

            //let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: false)]

            centralManager.scanForPeripherals(withServices: nil, options:  nil)
            isScanning = centralManager.isScanning
            sender.title = "Stop"
        } else {
            print("Unknown case")
        }
    }

    var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }

    private func showAlert(_ info: ScanInfo) {
        let alert = UIAlertController(title: "Ошибка",
                                      message: info.rawValue,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundedPeritherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "standartCell", for: indexPath) as! TableViewCell
        cell.inputPeripheral = foundedPeritherals[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        guard let peripheral = cell.inputPeripheral else { return }
        centralManager.connect(peripheral, options: nil)
    }
}

extension MyTableViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            currentStatusLabel.text = "unknown"
            isScanning = central.isScanning
        case .resetting:
            currentStatusLabel.text = "resetting"
            isScanning = central.isScanning
        case .unsupported:
            currentStatusLabel.text = "unsupported"
            isScanning = central.isScanning
        case .unauthorized:
            currentStatusLabel.text = "unauthorized"
            isScanning = central.isScanning
        case .poweredOff:
            currentStatusLabel.text = "poweredOff"
            isScanning = central.isScanning
        case .poweredOn:
            currentStatusLabel.text = "poweredOn"
            isScanning = central.isScanning
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !foundedPeritherals.contains(peripheral) {
            foundedPeritherals.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        showAlertWith(text: peripheral.description, message: #function)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        showAlertWith(text: "DEVICE:\n \(peripheral.description)\nERROR:\n\(error?.localizedDescription ?? "unknown error")", message: #function)
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        showAlertWith(text: "CBCentralManager. state: \(dict)", message: #function)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        showAlertWith(text: "DEVICE:\n \(peripheral.description)\nERROR:\n\(error?.localizedDescription ?? "unknown error")", message: #function)
    }

    func showAlertWith(text: String, message: String) {
        let alert = UIAlertController(title: text, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

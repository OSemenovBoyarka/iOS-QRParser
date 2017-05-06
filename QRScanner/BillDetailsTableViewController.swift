//
//  BillDetailsTableViewController.swift
//  QRScanner
//
//  Created by Alexander Semenov on 5/6/17.
//  Copyright © 2017 Dev Challenge. All rights reserved.
//

import UIKit

class BillDetailsTableViewController: UITableViewController {


    var items: [Item] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Your bill"
    }




    // MARK: tableview delegate and data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "billItem", for: indexPath)
        let item = items[indexPath.row]

        cell.textLabel!.text = item.name;

        let priceStr: String
        if let price = item.price {
            priceStr = String(describing: price)
        } else {
            priceStr = "??"
        }

        let quantityStr: String
        if let quantity = item.quantity {
            quantityStr = String(describing: quantity)
        } else {
            quantityStr = "??"
        }

        cell.detailTextLabel!.text = String(format: "%@ X %@", quantityStr, priceStr)

        return cell
    }

    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        //calculate sum for order
        var total: Decimal = 0
        for item in items {
            if let itemTotal = item.totalPrice() {
                total.add(itemTotal)
            }
        }
        return String(format: "Total: %@", String(describing: total))
    }


}
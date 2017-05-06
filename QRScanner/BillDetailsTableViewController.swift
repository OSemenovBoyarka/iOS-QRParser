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
        self.title = "Bar of Clones"
        self.tableView.tableFooterView = UIView()
    }

    fileprivate func totalSum() -> Decimal {
        //calculate sum for order
        var total: Decimal = 0
        for item in items {
            if let itemTotal = item.totalPrice() {
                total.add(itemTotal)
            }
        }
        return total
    }
}

// MARK: tableview delegate and data source
extension BillDetailsTableViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your waiter is Boba Fett 🤖"
    }
   
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //extra row for total
        return items.count+1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell
        if indexPath.row < items.endIndex {
            //normal item cell
            cell = tableView.dequeueReusableCell(withIdentifier: "bill_item", for: indexPath)
            (cell as! ItemTableViewCell).decorate(with: items[indexPath.row])
        } else {
            //total price cell
            cell = tableView.dequeueReusableCell(withIdentifier: "total_item", for: indexPath)
            (cell as! TotalTableViewCell).decorate(with: totalSum())
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, tableView.bounds.width);
        }
        return cell
    }
    
}

//MARK: custom tableview cells
class ItemTableViewCell : UITableViewCell {
    
    func decorate(with item: Item){
        
        self.textLabel!.text = item.name;
        
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
        
        self.detailTextLabel!.text = String(format: "%@ x %@", quantityStr, priceStr)
    }
}

class TotalTableViewCell : UITableViewCell {
    
    @IBOutlet weak var totalTextLabel: UILabel!
    
    func decorate(with totalPrice: Decimal){
       totalTextLabel.text = String(format:"TOTAL: %@", String(describing: totalPrice))
    }
}





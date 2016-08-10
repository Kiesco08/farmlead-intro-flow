//
//  PersonalizationTableViewController.swift
//  FarmLead
//
//  Created by Zoumite Franck Armel Mamboue on 2016-08-09.
//  Copyright © 2016 Zoumite Franck Armel Mamboue. All rights reserved.
//

import UIKit
import Alamofire

class PersonalizationTableViewController: UITableViewController {
    
    //MARK: UI Connections
    @IBOutlet weak var regionTextField: AutoCompleteTextField!
    @IBOutlet weak var commodityTextField: UITextField!
    
    //MARK: Constants
    let sectionNames = [NSLocalizedString("Where are you located?", comment: ""),
                        NSLocalizedString("Which unit do you prefer to deal with?", comment: "")]
    let sectionHeaderPadding: CGFloat = 20
    let commodityUnitPickerView = UIPickerView()
    
    //MARK: Variables
    var searchRequest: Alamofire.Request?
    var commodityUnits: [CommodityUnit]?
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = NSLocalizedString("Personalize your FarmLead", comment: "")
        
        setupViews()
    }
    
    //MARK: Functions
    func setupViews() {
        configureToolbar()
        customizeRegionTextField()
        customizeCommodityTextField()
        handleRegionTextFieldInterfaces()
    }
    
    func configureToolbar() {
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .Plain, target: self, action: #selector(doneAction))
        self.navigationItem.setRightBarButtonItem(doneButton, animated: false)
    }
    
    func doneAction() {
        let alertController = UIAlertController(title: NSLocalizedString("Done", comment: ""), message: NSLocalizedString("The demo is finished. Hope you enjoyed :)", comment: ""), preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: NSLocalizedString("Got it", comment: ""), style: .Default, handler: { action in
            
            self.dismissPopup()
            
        })
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func customizeRegionTextField() {
        self.regionTextField.delegate = self
        
        // Keyboard toolbar
        let emailKeyboardToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, SCREEN_WIDTH, 40))
        emailKeyboardToolbar.barStyle = UIBarStyle.Default
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: #selector(dismissKeyboard))
        emailKeyboardToolbar.setItems([space, done], animated: false)
        emailKeyboardToolbar.sizeToFit()
        
        self.regionTextField.inputAccessoryView = emailKeyboardToolbar
    }
    
    func customizeCommodityTextField() {
        self.commodityTextField.delegate = self
        
        // Keyboard toolbar
        let emailKeyboardToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, SCREEN_WIDTH, 40))
        emailKeyboardToolbar.barStyle = UIBarStyle.Default
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: #selector(dismissKeyboard))
        emailKeyboardToolbar.setItems([space, done], animated: false)
        emailKeyboardToolbar.sizeToFit()
        
        self.commodityTextField.inputAccessoryView = emailKeyboardToolbar
    }
    
    func setupCommodityPickerView() {
        commodityUnitPickerView.delegate = self
        self.commodityTextField.inputView = commodityUnitPickerView
        
        // Initialize commodity units if any
        if let commodityUnits = getCommodityUnits() {
            self.commodityUnits = commodityUnits
            commodityUnitPickerView.reloadAllComponents()
            var indexToSelect = 0
            if let selectedCommodityUnitId = getIntFromUserDefaults(SELECTED_COMMODITY_UNIT_KEY) {
                for (index, commodityUnit) in commodityUnits.enumerate() {
                    if commodityUnit.id == selectedCommodityUnitId {
                        indexToSelect = index
                        break
                    }
                }
            } else {
                print("No commodity unit saved")
            }
            setCommodity(commodityUnits, index: indexToSelect)
        }

    }
    
    func setCommodity(commodityUnits: [CommodityUnit], index: Int) {
        print("Setting commodity at index \(index): \(commodityUnits[index].name)")
        commodityTextField.text = commodityUnits[index].name
    }
    
    func handleRegionTextFieldInterfaces() {
        regionTextField.onTextChange = {[weak self] text in
            if !text.isEmpty && text.characters.count > 1 {
                if let searchRequest = self?.searchRequest {
                    searchRequest.cancel()
                }
                let triggerTime = (Int64(NSEC_PER_SEC) * SEARCH_DELAY)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    fetchRegions(text)
                })
            }
        }
        
// TODO: Implement when search API works
//        regionTextField.onSelect = {[weak self] text, indexpath in
//            
//        }
    }
    
    func calculateHeightForHeaderSection(section: Int) -> UIView {
        
        var text = " "
        if section < sectionNames.count {
            text = sectionNames[section]
        }
        // Create section title
        let lblSectionName = UILabel()
        lblSectionName.text = text
        lblSectionName.textColor = UIColor.lightGrayColor()
        lblSectionName.numberOfLines = 0
        lblSectionName.lineBreakMode = .ByWordWrapping
        lblSectionName.sizeToFit()
        
        // Create section title frame
        var frame = CGRectMake(0, 0, SCREEN_WIDTH, lblSectionName.frame.size.height)
        frame.origin.x = 10
        frame.origin.y = 10
        frame.size.width = self.view.bounds.size.width - frame.origin.x
        lblSectionName.frame = frame
        
        // Embed section title in a view
        frame.origin.x = 0
        frame.origin.y = 0
        let customView = UIView(frame: frame)
        customView.addSubview(lblSectionName)
        customView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        return customView

    }

}

//MARK: Protocol implementation
extension PersonalizationTableViewController: UITextFieldDelegate {
    // TODO: Implement when search API works
}

// MARK: - Table view data source
extension PersonalizationTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionNames.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return calculateHeightForHeaderSection(section).frame.size.height + sectionHeaderPadding // Padding
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return calculateHeightForHeaderSection(section)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.section {
            
        case 0: // LOCATION
            break
            
        case 1: // COMMODITY
            break
            
        default:
            break
            
        }
    }
}

extension PersonalizationTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if let commodityUnits = commodityUnits {
            return commodityUnits.count
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return commodityUnits?[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Get level select and update its name on the UI
        guard let selectedCommodityUnit = commodityUnits?[row] else {
            return
        }
        
        commodityTextField.text = selectedCommodityUnit.name
        
        print("****")
        print(selectedCommodityUnit.id)
        print(selectedCommodityUnit.name)
        print("****")
        
        if let selectedCommodityUnitId = selectedCommodityUnit.id {
            saveCommodityId(selectedCommodityUnitId)
        }
    }
}

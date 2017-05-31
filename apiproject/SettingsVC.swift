//
//  SettingsVC.swift
//  apiproject
//
//  Created by Johan Wejdenstolpe on 2017-05-15.
//  Copyright © 2017 Johan Wejdenstolpe. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let searchResults = (1...10).map { $0 * 5 }
    let searchRadius = (5...20).map { $0 * 100 }
    let moveRadius = (1...10).map { $0 * 50 }
    let userSettings = UserDefaults()
    
    var pickerArray: [Int] = [Int]()
    var selectedRow: Int = 0
    
    @IBOutlet weak var settingsPickerView: UIPickerView!
    @IBOutlet weak var lblSearchResult: UILabel!
    @IBOutlet weak var lblSearchRadius: UILabel!
    @IBOutlet weak var lblMoveRadius: UILabel!
    @IBOutlet weak var pickerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsPickerView.delegate = self
        settingsPickerView.dataSource = self
        
        if let results = userSettings.string(forKey: "SearchResult") {
            lblSearchResult.text = "\(results) st"
        }
        if let radius = userSettings.string(forKey: "SearchRadius") {
            lblSearchRadius.text = "\(radius) m"
        }
        if let radiusMove = userSettings.string(forKey: "MoveRadius") {
            lblMoveRadius.text = "\(radiusMove) m"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchResultTapped(_ sender: UITapGestureRecognizer) {

        
        pickerArray = searchResults
        if let results = Int(userSettings.string(forKey: "SearchResult")!) {
            if let row = pickerArray.index(of: results) {
                selectedRow = row
            }
        }
        pickerLabel.text = "Välj antal sökresultat"
        showPickerView()
    }
    @IBAction func viewTap(_ sender: UITapGestureRecognizer) {
        settingsPickerView.isHidden = true
        pickerLabel.isHidden = true
    }
    @IBAction func searchRadiusTapped(_ sender: UITapGestureRecognizer) {

        pickerArray = searchRadius
        if let radius = Int(userSettings.string(forKey: "SearchRadius")!) {
            if let row = pickerArray.index(of: radius) {
                selectedRow = row
            }
        }
        pickerLabel.text = "Välj sökradie"
        showPickerView()
    }
    @IBAction func moveRadiusTapped(_ sender: UITapGestureRecognizer) {

        pickerArray = moveRadius
        if let radiusMove = Int(userSettings.string(forKey: "MoveRadius")!) {
            if let row = pickerArray.index(of: radiusMove) {
                selectedRow = row
            }
        }
        pickerLabel.text = "Välj uppdateringsradie"
        showPickerView()
    }
    
    func showPickerView(){
        settingsPickerView.reloadAllComponents()
        settingsPickerView.selectRow(selectedRow, inComponent: 0, animated: true)
        pickerLabel.isHidden = false
        settingsPickerView.isHidden = false
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerArray[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerArray.last == 50{
            lblSearchResult.text = "\(pickerArray[row]) st"
            userSettings.setValue("\(pickerArray[row])", forKey: "SearchResult")
        }
        if pickerArray.last == 2000{
            lblSearchRadius.text = "\(pickerArray[row]) m"
            userSettings.setValue("\(pickerArray[row])", forKey: "SearchRadius")
        }
        if pickerArray.last == 500{
            lblMoveRadius.text = "\(pickerArray[row]) m"
            userSettings.setValue("\(pickerArray[row])", forKey: "MoveRadius")
        }
    }
}

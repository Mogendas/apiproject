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
    
    @IBOutlet weak var settingsPickerView: UIPickerView!
    @IBOutlet weak var lblSearchResult: UILabel!
    @IBOutlet weak var lblSearchRadius: UILabel!
    @IBOutlet weak var lblMoveRadius: UILabel!
    
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
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
//        if sender.view?.tag == 1 {
//            print("1")
//        }
//        if sender.view?.tag == 2 {
//            print("2")
//        }
//        if sender.view?.tag == 3 {
//            print("3")
//        }
//        
//    }
    @IBAction func searchResultTapped(_ sender: UITapGestureRecognizer) {
//        print("1")
        pickerArray = searchResults
        showPickerView()
    }
    @IBAction func viewTap(_ sender: UITapGestureRecognizer) {
        settingsPickerView.isHidden = true
    }
    @IBAction func searchRadiusTapped(_ sender: UITapGestureRecognizer) {
//        print("2")
        pickerArray = searchRadius
        showPickerView()
    }
    @IBAction func moveRadiusTapped(_ sender: UITapGestureRecognizer) {
//        print("3")
        pickerArray = moveRadius
        showPickerView()
    }
    
    func showPickerView(){
        settingsPickerView.reloadAllComponents()
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
//            print("searchResults")
//            print("\(pickerArray[row])")
            lblSearchResult.text = "\(pickerArray[row]) st"
            userSettings.setValue("\(pickerArray[row])", forKey: "SearchResult")
//            saveSettings()
        }
        if pickerArray.last == 2000{
//            print("searchRadius")
//            print("\(pickerArray[row])")
            lblSearchRadius.text = "\(pickerArray[row]) m"
            userSettings.setValue("\(pickerArray[row])", forKey: "SearchRadius")
//            saveSettings()
        }
        if pickerArray.last == 500{
//            print("moveRadius")
//            print("\(pickerArray[row])")
            lblMoveRadius.text = "\(pickerArray[row]) m"
            userSettings.setValue("\(pickerArray[row])", forKey: "MoveRadius")
//            saveSettings()
        }
        
        
    }
    
    func saveSettings(){
        userSettings.setValue(lblSearchResult.text, forKey: "SearchResult")
        userSettings.setValue(lblSearchRadius.text, forKey: "SearchRadius")
        userSettings.setValue(lblMoveRadius.text, forKey: "MoveRadius")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

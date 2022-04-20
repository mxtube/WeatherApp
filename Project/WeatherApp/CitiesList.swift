//
//  ViewController.swift
//  WeatherApp
//
//  Created by Кирилл Кузнецов on 15.03.2022.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftUI

// Class for Table cities
class CitiesList: UITableViewController {
    
    // Array for city list
    var cities: [City] = []
    // URL API
    let url = "http://api.weatherapi.com/v1/current.json?key=\(apiKey)&aqi=no"
    
    // Count row in section for table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    // Configure row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityRow", for: indexPath) as! CityCell
        
        cell.cityName.text = cities[indexPath.row].name
        cell.cityTemp.text = String(cities[indexPath.row].temp_c)
        
        return cell
    }
    
    // Event for tap add new city
    @IBAction func addCityAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add new city", message: "Enter city name", preferredStyle: .alert)
        alertController.addTextField { textField in textField.placeholder = "City name" }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            guard alertController.textFields![0].text != nil else { return }
            let name = alertController.textFields![0].text!
            self.requestData(city: name)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Function for request API and save in array
    func requestData(city: String) {
        let params = ["q": city]
        AF.request(url, method: .get, parameters: params).response { [self] response in
            switch response.result {
            case .success(let value):
                let json = JSON(value!)
                let name = json["location"]["name"].stringValue
                let temp_c = json["current"]["temp_c"].doubleValue
                let country = json["location"]["country"].stringValue
                guard !checkCity(name: name) else { return alertController(message: "City already added") }
                cities.append(City(name: name, temp_c: temp_c, country: country))
                tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Function checker city in array
    func checkCity(name: String) -> Bool {
        cities.contains { list in
            return list.name == name
        }
    }
    
    // Alert Controller for errors
    func alertController(message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}


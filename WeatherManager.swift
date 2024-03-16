//
//  WeatherManager.swift
//  Clima
//
//  Created by Antt Min on 3/13/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager, weather : WeatherModel)
    func didFailWithError(error : Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=eede5bc54f59d15288fd02bed29a32f2&units=metric"
    
    func fetchWeather(cityName : String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        self.performRequest(with: urlString)
    }
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(latitude : CLLocationDegrees, longitude : CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString : String){
        //Create URL
        if let url = URL(string: urlString){
            //Create a URLSession
            let session = URLSession(configuration: .default)
            
            //Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather : weather)
                    }
                }
            }
            
            //Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData : Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
//            print(weather.conditionName)
//            print(weather.temperatureString)
//            print(temp)
 //           print(getConditionName(weatherId: id))
//            print(decodedData.main.temp)
//            print(decodedData.weather[0].description)
//            print(decodedData.weather[0].id)
        }catch {
            //print(error)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
// 26line in using
//    func handle(data : Data?, response : URLResponse?, error : Error?){
//        if error != nil {
//            //print(error!)
//            return
//        }
//
//        if let safeData = data {
//            let dataString = String(data: safeData, encoding: .utf8)
//            //print(dataString)
//        }
//    }
    
    
    
}

//
//  File.swift
//  weatherProject
//
//  Created by 표현수 on 2023/01/04.
//

import UIKit
import WeatherKit
import CoreLocation

class DefaultPageViewController: UIViewController, CLLocationManagerDelegate {
    
    //현재 날씨
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var weatherRegionLabel: UILabel!
    @IBOutlet weak var weatherTempLabel: UILabel!
    @IBOutlet weak var weatherDateLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherMaxTempLabel: UILabel!
    @IBOutlet weak var weatherMinTempLabel: UILabel!
    
    //서울의 좌표
    var myLocation = CLLocation(latitude: 37.5666, longitude: 126.9784)
    //위치
    var location = ""
    //날씨 데이터 저장
    var weather: Weather?
    //날씨 컨디션 저장
    var currentWeatherCondition = ""
    //시간당 온도
    var hourWeatherTempArray: [String] = []
    var hourWeatherSymbol: [String] = []
    //10일간 최고 최저 온도
    var weekWeatherMaxTempArray: [Int] = []
    var weekWeatherMinTempArray: [Int] = []
    var weekWeatherSymbolArray: [String] = []
    //오늘 온도, 최고 최저 온도, 심볼네임
    var currentWeatherTemp: Int = 0
    var currentWeatherSymbol = ""
    var dailyWeatherMaxTemp: Int = 0
    var dailyWeatherMinTemp: Int = 0
    //가시거리
    var currentWeatherVisibility: Int = 0
    //자외선 지수
    var currentWeatherUvIndex: Int = 0
    //풍속, 풍향
    var currentWeatherWindSpeed: Int = 0
    var currentWeatherWinddirection = ""
    //체감온도
    var currentWeatherApparentTemperature: Int = 0
    //습도
    var currentWeatherHumidity: Int = 0
    //이슬점
    var currentWeatherDewPoint: Int = 0
    //강수량
    var precipitation: Int = 0
    
    var indexNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.weatherView.isUserInteractionEnabled = true

        self.weatherView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.weatherViewTapped)))
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 16

        //위치 매니저 생성 및 설정
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case .notDetermined, .restricted:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("위치 서비스 허용 꺼짐")
            self.location = "서울"
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            self.myLocation = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
            self.location = "나의 위치"
        @unknown default:
            break
        }

        //weatherkit 사용
        let weatherService = WeatherService.shared
        
        DispatchQueue.main.async {
            Task {
                do {
                    self.weather = try await weatherService.weather(for: self.myLocation)
                    //10일간 날씨 받아오기
                    for i in 0...9 {
                        self.weekWeatherMaxTempArray.append(Int(round(self.weather!.dailyForecast[i].highTemperature.value)))
                        self.weekWeatherMinTempArray.append(Int(round(self.weather!.dailyForecast[i].lowTemperature.value)))
                        self.weekWeatherSymbolArray.append(self.weather!.dailyForecast[i].symbolName)
                    }
                    print(self.weekWeatherSymbolArray)
                    print(self.weather!.currentWeather.condition)
                    print(self.weather!.currentWeather.symbolName)
                    print(self.weather!.currentWeather.condition)
                    //현재시간 불러오기
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "ko")
                    formatter.dateFormat = "HH"
                    let currentHour = Int(formatter.string(from: Date()))!
                    //시간당 날씨 받아오기
                    for j in (currentHour + 2)...(currentHour + 25) {
                        self.hourWeatherTempArray.append("\(Int(round(self.weather!.hourlyForecast[j].temperature.value)))º")
                        self.hourWeatherSymbol.append(self.weather!.hourlyForecast[j].symbolName)
                    }

                    //현재 날씨 받아오기
                    self.currentWeatherCondition = self.weather!.currentWeather.condition.rawValue
                    self.dailyWeatherMaxTemp = Int(round(self.weather!.dailyForecast[0].highTemperature.value))
                    self.dailyWeatherMinTemp = Int(round(self.weather!.dailyForecast[0].lowTemperature.value))
                    self.currentWeatherSymbol = self.weather!.currentWeather.symbolName
                    self.currentWeatherTemp = Int(round(self.weather!.currentWeather.temperature.value))
                    self.currentWeatherVisibility = Int(round(self.weather!.currentWeather.visibility.value / 1000))
                    self.currentWeatherUvIndex = self.weather!.currentWeather.uvIndex.value
                    self.currentWeatherWindSpeed = Int(round(self.weather!.currentWeather.wind.speed.value / 3.6))
                    self.currentWeatherWinddirection = "\(self.weather!.currentWeather.wind.compassDirection.rawValue)"
                    print(self.currentWeatherWinddirection)
                    self.currentWeatherApparentTemperature = Int(round(self.weather!.currentWeather.apparentTemperature.value))
                    self.currentWeatherHumidity = Int(round(self.weather!.currentWeather.humidity * 100))
                    self.precipitation = Int(round(self.weather!.dailyForecast[0].precipitationChance * 100))
                    self.currentWeatherDewPoint = Int(round(self.weather!.currentWeather.dewPoint.value))
                    
                    //ui세팅
                    self.currentWeatherConditionKO()
                    self.setWeatherUI()
//                    self.weekWeatherTableView.reloadData()
                } catch {
                    print("error")
                }
            }
        }
    }
    
    //현재 온도 세팅
    private func setWeatherUI() {
        //오늘 날짜 표시
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        weatherDateLabel.text = formatter.string(from: Date())
        weatherRegionLabel.text = "나의 위치"

        weatherLabel.text = self.currentWeatherCondition
        //현재온도
        weatherTempLabel.text = "\(self.currentWeatherTemp)º"
        //최고온도
        weatherMaxTempLabel.text = "최고:\(self.dailyWeatherMaxTemp)º"
        //최저온도
        weatherMinTempLabel.text = "최저:\(self.dailyWeatherMinTemp)º"
        //심볼네임
        weatherImage.image = UIImage(named: self.currentWeatherSymbol)
    }
    
    //현재 날씨 뷰를 눌렀을 때
    @objc func weatherViewTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showDefaultCurrentWeatherView", sender: sender)
    }
    
    //currnetViewController로 데이터 전송
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDefaultCurrentWeatherView" {
            guard let vc = segue.destination as? DefaultCurrentWeatherViewController else { return }
            vc.currentWeatherCondition = self.currentWeatherCondition
            vc.hourWeatherTempArray = self.hourWeatherTempArray
            vc.weekWeatherSymbolArray = self.weekWeatherSymbolArray
            vc.weekWeatherMaxTempArray = self.weekWeatherMaxTempArray
            vc.weekWeatherMinTempArray = self.weekWeatherMinTempArray
            vc.currentWeatherTemp = self.currentWeatherTemp
            vc.currentWeatherSymbol = self.currentWeatherSymbol
            vc.dailyWeatherMaxTemp = self.dailyWeatherMaxTemp
            vc.dailyWeatherMinTemp = self.dailyWeatherMinTemp
            vc.hourWeatherSymbol = self.hourWeatherSymbol
            vc.currentWeatherVisibility = self.currentWeatherVisibility
            vc.currentWeatherUvIndex = self.currentWeatherUvIndex
            vc.currentWeatherWindSpeed = self.currentWeatherWindSpeed
            vc.currentWeatherWinddirection = self.currentWeatherWinddirection
            vc.currentWeatherApparentTemperature = self.currentWeatherApparentTemperature
            vc.currentWeatherHumidity = self.currentWeatherHumidity
            vc.currentWeatherDewPoint = self.currentWeatherDewPoint
            vc.precipitation = self.precipitation
            vc.location = self.location
        }
    }
    
    //날씨 컨디션 케이스별 번역
    func currentWeatherConditionKO() {
        switch currentWeatherCondition {
        case "blowingDust":
            currentWeatherCondition = "먼지"
        case "clear":
            currentWeatherCondition = "맑음"
        case "cloudy":
            currentWeatherCondition = "흐림"
        case "foggy":
            currentWeatherCondition = "안개"
        case "haze":
            currentWeatherCondition = "연무"
        case "mostlyClear":
            currentWeatherCondition = "대체로 맑음"
        case "mostlyCloudy":
            currentWeatherCondition = "대체로 흐림"
        case "partlyCloudy":
            currentWeatherCondition = "한때 흐림"
        case "smoky":
            currentWeatherCondition = "연기"
        case "breezy":
            currentWeatherCondition = "미풍"
        case "windy":
            currentWeatherCondition = "바람"
        case "drizzle":
            currentWeatherCondition = "이슬비"
        case "heavyRain":
            currentWeatherCondition = "폭우"
        case "isolatedThunderstorms":
            currentWeatherCondition = "외딴뇌우"
        case "rain":
            currentWeatherCondition = "비"
        case "sunShowers":
            currentWeatherCondition = "소나기"
        case "scatteredThunderstorms":
            currentWeatherCondition = "흩어진뇌우"
        case "strongStorms":
            currentWeatherCondition = "폭풍"
        case "thunderstorms":
            currentWeatherCondition = "뇌우"
        case "frigid":
            currentWeatherCondition = "몹시 추움"
        case "hail":
            currentWeatherCondition = "우박"
        case "hot":
            currentWeatherCondition = "더움"
        case "flurries":
            currentWeatherCondition = "돌풍"
        case "sleet":
            currentWeatherCondition = "진눈깨비"
        case "snow":
            currentWeatherCondition = "눈"
        case "sunFlurries":
            currentWeatherCondition = "소낙눈"
        case "wintryMix":
            currentWeatherCondition = "눈, 비"
        case "blizzard":
            currentWeatherCondition = "눈보라"
        case "blowingSnow":
            currentWeatherCondition = "날린눈"
        case "freezingDrizzle":
            currentWeatherCondition = "언 진눈깨비"
        case "freezingRain":
            currentWeatherCondition = "얼어붙은 비"
        case "heavySnow":
            currentWeatherCondition = "폭설"
        case "hurricane":
            currentWeatherCondition = "허리케인"
        case "tropicalStorm":
            currentWeatherCondition = "열대 폭풍"
        default:
            break
        }
    }
    
    static func getInstance() -> DefaultPageViewController {

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DefaultPageViewController") as! DefaultPageViewController
        
        return vc
    }
}

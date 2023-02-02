//
//  CustomPageViewController.swift
//  weatherProject
//
//  Created by 표현수 on 2022/12/28.
//

import UIKit
import MapKit

class CustomPageViewController: UIPageViewController, UIPageViewControllerDelegate {
    
    var individualPageViewControllerList = [UIViewController]()
    let pageControl = UIPageControl()
    //현재 인덱스
    var currentIndex = 1
    
    // 페이지컨트롤 인디케이터 상세 설정
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews{
            if view is UIPageControl{
                (view as! UIPageControl).currentPageIndicatorTintColor = .black
                (view as! UIPageControl).pageIndicatorTintColor = .gray
                (view as! UIPageControl).setIndicatorImage(UIImage(systemName: "plus"), forPage: 0)
                (view as! UIPageControl).currentPage = currentIndex
                (view as! UIPageControl).numberOfPages = individualPageViewControllerList.count
                (view as! UIPageControl).isUserInteractionEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = nil
        self.dataSource = self
        self.delegate = self
        
        weatherCard()
        addNotiObserver()
        delNotiObserver()
    }
    
    // 현재 날씨 카드
    func weatherCard() {
        individualPageViewControllerList.append(AddWeatherCardViewController.getInstance())
        individualPageViewControllerList.append(DefaultPageViewController.getInstance())
        //userDefault를 사용하여 데이터 세팅
        if let defaultMapItemArray = UserDefaults.standard.array(forKey: "key") as? [[String]] {
            for i in 0..<defaultMapItemArray.count {
                let mapItem = defaultMapItemArray[i]
                individualPageViewControllerList.append(PageDetailViewController.getInstance(locality: mapItem[0], country: mapItem[1], latitude: mapItem[2], longitude: mapItem[3]))
            }
        }
        setViewControllers([individualPageViewControllerList[1]], direction: .forward, animated: false, completion: nil)
    }
    //날씨카드 추가 노티피케이션 옵져버
    private func addNotiObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(addVC), name: NSNotification.Name("addVC"), object: nil)
    }
    //날씨카드 삭제 노티피케이션 옵져버
    private func delNotiObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(delVC), name: NSNotification.Name("delVC"), object: nil)
    }
    //추가 함수
    @objc func addVC(notification: NSNotification) {
        if let mapItemArray = notification.object as? [String] {
            individualPageViewControllerList.append(PageDetailViewController.getInstance(locality: mapItemArray[0], country: mapItemArray[1], latitude: mapItemArray[2], longitude: mapItemArray[3]))
            //userDefault에 저장
            if var defaultMapItemArray = UserDefaults.standard.array(forKey: "key") as? [[String]] {
                defaultMapItemArray.append(mapItemArray)
                UserDefaults.standard.setValue(defaultMapItemArray, forKey: "key")
            } else {
                var defaultMapItemArray: [[String]] = []
                defaultMapItemArray.append(mapItemArray)
                UserDefaults.standard.setValue(defaultMapItemArray, forKey: "key")
            }
            //현재 인덱스 업데이트
            currentIndex = 1
            setViewControllers([individualPageViewControllerList[1]], direction: .forward, animated: false)
        }
    }
    //삭제 함수
    @objc func delVC(notification: NSNotification) {
        if let _ = notification.object as? String {
            individualPageViewControllerList.remove(at: currentIndex)
            //default부분 삭제
            if var defaultMapItemArray = UserDefaults.standard.array(forKey: "key") as? [[String]] {
                defaultMapItemArray.remove(at: currentIndex - 2)
                UserDefaults.standard.setValue(defaultMapItemArray, forKey: "key")
            }
            //현재 인덱스 업데이트
            currentIndex = 1
            setViewControllers([individualPageViewControllerList[1]], direction: .forward, animated: false)
        }
    }
}

// MARK: - 페이지컨트롤 인디케이터!!

extension CustomPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let indexOfCurrentPageViewController = individualPageViewControllerList.firstIndex(of: viewController) else { return nil }
        //현재 인덱스
        currentIndex = indexOfCurrentPageViewController
        print(currentIndex)
        let previousIndex = indexOfCurrentPageViewController - 1
        if indexOfCurrentPageViewController == 1 {
            return individualPageViewControllerList[0]
        } else if previousIndex < 0 {
            return nil
        } else {
            return individualPageViewControllerList[previousIndex]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentindexOfPageViewController = individualPageViewControllerList.firstIndex(of: viewController) else { return nil }
        //현재 인덱스
        currentIndex = currentindexOfPageViewController
        print(currentIndex)
        let nextIndex = currentindexOfPageViewController + 1
        
        if nextIndex == individualPageViewControllerList.count {
            return nil
        } else {
            return individualPageViewControllerList[nextIndex]
        }
    }
}

extension CustomPageViewController {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return individualPageViewControllerList.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}


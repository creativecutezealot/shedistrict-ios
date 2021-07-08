//  PageProfileViewBoosts.swift
//  SheDistrict
//  Created by iOS-Appentus on 31/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit


class PageProfileViewBoosts: UIPageViewController , UIPageViewControllerDelegate, UIPageViewControllerDataSource , UIScrollViewDelegate{
    var pages = [UIViewController]()
    var curr = Int()
    var current = Int()
    
    var last_x : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        let storyboard = UIStoryboard (name: "Main_2", bundle: nil)
        let page_1 = storyboard.instantiateViewController(withIdentifier: "ProfileViewsVC") as! ProfileViewsVC
        let page_2 = storyboard.instantiateViewController(withIdentifier: "BoostsViewController") as! BoostsViewController
        
        pages.append(page_1)
        pages.append(page_2)

        setViewControllers([page_1], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.move_by_buttons(_:)), name: Notification.Name("move_by_buttons_events"), object: nil)
    }
    
    @objc func move_by_buttons(_ sender:NSNotification) {
        let index = sender.object as! Int

        if index == 1 {
            self.setViewControllers([pages[index]], direction:.forward, animated:true, completion: nil)
        } else {
            self.setViewControllers([pages[index]], direction: .reverse, animated:true, completion: nil)
        }

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController)-> UIViewController? {
        curr = pages.index(of: viewController)!
        
//        NotificationCenter.default.post(name: NSNotification.Name (rawValue:"selected_events"), object:curr)
        
        // if you prefer to NOT scroll circularly, simply add here:
        if curr == 0 { return nil }
        let prev = abs((curr - 1) % pages.count)
        return pages[prev]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController)-> UIViewController? {
        let current = pages.firstIndex(of: viewController)!
        
//        NotificationCenter.default.post(name: NSNotification.Name (rawValue:"selected_events"), object:current)
        
        if current == (pages.count - 1) { return nil }
        let nxt = abs((current + 1) % pages.count)
        return pages[nxt]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if (!completed)
        {
            return
        }
        if previousViewControllers[0] != pages[0]{
//            NotificationCenter.default.post(name: Notification.Name("get_offset_set_view"), object: 0)
        }else{
//            NotificationCenter.default.post(name: Notification.Name("get_offset_set_view"), object: UIScreen.main.bounds.width/2)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        for View in self.view.subviews{
            if View.isKind(of: UIScrollView.self){
                let ScrollV = View as! UIScrollView
                ScrollV.isScrollEnabled = false
            }
            
        }
    }
    
}


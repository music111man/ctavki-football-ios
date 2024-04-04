//
//  UIPageViewController.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 04.04.2024.
//

import RxCocoa
import RxSwift
import UIKit

extension UIPageViewController: HasDelegate { }

class UIPageViewControllerDelegateProxy: DelegateProxy<UIPageViewController, UIPageViewControllerDelegate>, DelegateProxyType, UIPageViewControllerDelegate {

    init(parentObject: UIPageViewController) {
        super.init(
            parentObject: parentObject,
            delegateProxy: UIPageViewControllerDelegateProxy.self
        )
    }

    public static func registerKnownImplementations() {
        self.register { UIPageViewControllerDelegateProxy(parentObject: $0) }
    }
}

class UIPageViewControllerDataSourceProxy: DelegateProxy<UIPageViewController, UIPageViewControllerDataSource>, DelegateProxyType, UIPageViewControllerDataSource {
    static func currentDelegate(for object: UIPageViewController) -> UIPageViewControllerDataSource? {
        object.dataSource
    }
    
    static func setCurrentDelegate(_ delegate: UIPageViewControllerDataSource?, to object: UIPageViewController) {
        object.dataSource = delegate
    }
    
    
    init(parentObject: UIPageViewController) {
        super.init(
            parentObject: parentObject,
            delegateProxy: UIPageViewControllerDataSourceProxy.self
        )
    }

    public static func registerKnownImplementations() {
        self.register { UIPageViewControllerDataSourceProxy(parentObject: $0) }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        prevControllerRelay.value
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        nextControllerRelay.value
    }
    
    fileprivate let nextControllerRelay = BehaviorRelay<UIViewController?>(value: nil)
    fileprivate let prevControllerRelay = BehaviorRelay<UIViewController?>(value: nil)
}


extension Reactive where Base: UIPageViewController {

    var delegate: UIPageViewControllerDelegateProxy {
        UIPageViewControllerDelegateProxy.proxy(for: base)
    }

    var didScroll: ControlEvent<Bool> {
        ControlEvent(events: delegate.methodInvoked(#selector(UIPageViewControllerDelegate.pageViewController(_:didFinishAnimating:previousViewControllers:transitionCompleted:)))
            .map { ($0[1] as! Bool && $0[3] as! Bool) })
    }
}

//
// PageViewController
//

import UIKit

// 페이지 컨트롤러 딜리게이트
public protocol PageViewControllerDelegate: class {
    /**
     페이지 컨트롤러 처음 시작시
     */
    func pageViewController(_ pageViewController: UIPageViewController, count: Int)
    /**
     페이지 컨트롤러 이동시 인덱스
     */
    func pageViewController(_ pageViewController: UIPageViewController, index: Int)
    /**
     페이지 컨트롤러 이동 안됨
     */
    func pageViewControllerError(_ index: Int)
    /**
     선택된 버튼
     */
    func pageButtonGroupViewButtonSelectedButton(_ button: UIButton)
    /**
     선택 안된 버튼
     */
    func pageButtonGroupViewButtonUnselectedButton(_ button: UIButton)
}

public extension PageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, count: Int) { }
    func pageViewController(_ pageViewController: UIPageViewController, index: Int) { }
    func pageViewControllerError(_ index: Int) { }
}

public class PageViewController: UIPageViewController {
    public weak var pageViewDelegate: PageViewControllerDelegate?
    
    /// 뷰컨트롤러
    public lazy var orderedViewControllers: [UIViewController] = [UIViewController]()
    
    /// 리로드 될지 안될지
    public var isReload = false
    
    /// 페이지컨트롤러가 활성화인지
    public var isEnabledScroll = true
    
    private var pageButtonGroupView: PageButtonGroupView?
    
    // MARK: initialize
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    // MARK: func
    
    /// 스와이프 활성화
    public func setDataSource() {
        self.dataSource = self
    }
    
    public func setPageButtonGroupView(_ pageButtonGroupView: PageButtonGroupView) {
        self.pageButtonGroupView = pageButtonGroupView
        self.pageButtonGroupView?.delegate = self
    }
    
    /// init View
    public func initView(_ viewController: [UIViewController]) {
        self.orderedViewControllers = viewController
        if let initialViewController = self.orderedViewControllers.first {
            self.scrollToViewController(initialViewController)
        }
        self.pageViewDelegate?.pageViewController(self, count: orderedViewControllers.count)
    }
    
    
    /// 다음 스크롤
    public func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            if !self.isEnabledScroll { return }
            self.isEnabledScroll = false
            self.pageButtonGroupView?.buttonEnabled = self.isEnabledScroll
            self.scrollToViewController(nextViewController)
        }
    }
    
    /// 스크롤 이동
    public func scrollToViewController(_ index: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = index >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[index]
            self.scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    /// New ViewController
    public static func newViewController(_ id: String, storyBoard: String) -> UIViewController {
        return UIStoryboard(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: "\(id)")
    }
    
    /// Scroll To ViewController
    private func scrollToViewController(_ viewController: UIViewController, direction: UIPageViewController.NavigationDirection = .forward, isNotify: Bool = true) {
        let animated = (viewController != self.viewControllers?.first)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if !self.isEnabledScroll {
                    self.isEnabledScroll = true
                    self.pageButtonGroupView?.buttonEnabled = self.isEnabledScroll
                }
            }
        }
        self.setViewControllers([viewController], direction: direction, animated: animated) { _ in
            self.notifyDelegateOfNewIndex()
        }
        CATransaction.commit()
    }
    
    /// Notify NewIndex
    private func notifyDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            self.pageButtonGroupView?.selectedLine(index)
            self.pageViewDelegate?.pageViewController(self, index: index)
        }
    }
    
}

// MARK: UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.isEnabledScroll {
                self.isEnabledScroll = true
                self.pageButtonGroupView?.buttonEnabled = self.isEnabledScroll
            }
        }
        self.notifyDelegateOfNewIndex()
    }
}

// MARK: UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        if !self.isReload {
            if previousIndex < 0 { return nil }
        }
        guard previousIndex >= 0 else { return orderedViewControllers.last }
        guard orderedViewControllers.count > previousIndex else { return nil }
        return orderedViewControllers[previousIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        if !self.isReload {
            if nextIndex >= orderedViewControllers.count { return nil }
        }
        guard orderedViewControllers.count != nextIndex else { return orderedViewControllers.first }
        return orderedViewControllers[nextIndex]
    }
}

// MARK: UIPageViewControllerDelegate
extension PageViewController: PageButtonGroupViewDelegate {
    public func pageButtonGroupViewButtonTap(_ button: UIButton, index: Int) {
        self.isEnabledScroll = false
        self.pageButtonGroupView?.buttonEnabled = self.isEnabledScroll
        self.scrollToViewController(index)
    }
    public func pageButtonGroupViewButtonIsTap(_ button: UIButton, index: Int) -> Bool {
        if let pageButtonGroupView = self.pageButtonGroupView, pageButtonGroupView.selectedIndex != index {
            return true
        }
        self.pageViewDelegate?.pageViewControllerError(index)
        return false
    }
    public func pageButtonGroupViewButtonSelectedButton(_ button: UIButton) {
        self.pageViewDelegate?.pageButtonGroupViewButtonSelectedButton(button)
    }
    public func pageButtonGroupViewButtonUnselectedButton(_ button: UIButton) {
        self.pageViewDelegate?.pageButtonGroupViewButtonUnselectedButton(button)
    }
}

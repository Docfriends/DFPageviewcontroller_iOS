//
// PageButtonGroupView
//

import UIKit

protocol PageButtonGroupViewDelegate: AnyObject {
    func pageButtonGroupViewButtonIsTap(_ button: UIButton, index: Int) -> Bool
    func pageButtonGroupViewButtonTap(_ button: UIButton, index: Int)
    func pageButtonGroupViewButtonSelectedButton(_ button: UIButton)
    func pageButtonGroupViewButtonUnselectedButton(_ button: UIButton)
}

public extension UIButton {
    convenience init(title: String, type: UIButton.ButtonType) {
        self.init(type: type)
        self.setTitle(title, for: .normal)
    }
}

open class PageButtonGroupView: UIView {
    
    weak var delegate: PageButtonGroupViewDelegate?
    
    // MARK: Public
    
    /**
     하단 라인
     */
    public lazy var bottomLineView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        let bottomLineHeightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 1)
        self.bottomLineHeightConstraint = bottomLineHeightConstraint
        view.addConstraint(bottomLineHeightConstraint)
        return view
    }()
    
    /**
     하단 라인 높이
     */
    public var bottomLineHeight: CGFloat {
        set {
            self.bottomLineHeightConstraint?.constant = newValue
        }
        get {
            return self.bottomLineHeightConstraint?.constant ?? 0
        }
    }
    
    /**
     선택 라인 높이
     */
    public var selectedLineHeight: CGFloat {
        set {
            self.selectedLineHeightConstraint?.constant = newValue
        }
        get {
            return self.selectedLineHeightConstraint?.constant ?? 0
        }
    }
    
    /**
     선택한 하단 라인
     */
    public lazy var selectedLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let selectedLineHeightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 2)
        view.addConstraint(selectedLineHeightConstraint)
        self.selectedLineHeightConstraint = selectedLineHeightConstraint
        return view
    }()
    
    /**
     선택한 하단 라인
     */
    public lazy var selectedLineContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let selectedLineHeightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 2)
        view.addConstraint(selectedLineHeightConstraint)
        view.backgroundColor = .clear
        return view
    }()
    
    /**
     선택한 하단 라인 width와 버튼width 차이. 0이면 버튼과 동일크기, 10이면 버튼보다 10이 작음
     */
    public var selectedWidthMargin: CGFloat = 10
    
    /**
     선택한 하단라인 위치
     */
    public var selectedBottomMargin: CGFloat = -1.5
    
    /**
     선택된 인덱스
     */
    public var selectedIndex: Int {
        set {
            self._selectedIndex = newValue
            self.selectedLine(newValue)
        }
        get {
            return self._selectedIndex ?? 0
        }
    }
    
    /**
     버튼 활성화
     */
    public var buttonEnabled: Bool {
        set {
            self.buttons.forEach({ $0.isUserInteractionEnabled = newValue })
        }
        get {
            return self.buttons.first?.isUserInteractionEnabled ?? true
        }
    }
    
    public var enabledColor: UIColor? {
        didSet {
            self.buttons.enumerated().filter({ $0.offset == self.selectedIndex }).forEach({ $0.element.setTitleColor(self.enabledColor, for: .normal) })
        }
    }
    
    public var enabledFont: UIFont? {
        didSet {
            self.buttons.enumerated().filter({ $0.offset == self.selectedIndex }).forEach({ $0.element.titleLabel?.font = self.enabledFont })
        }
    }
    
    public var unenabledColor: UIColor? {
        didSet {
            self.buttons.enumerated().filter({ $0.offset != self.selectedIndex }).forEach({ $0.element.setTitleColor(self.unenabledColor, for: .normal) })
        }
    }
    
    public var unenabledFont: UIFont? {
        didSet {
            self.buttons.enumerated().filter({ $0.offset != self.selectedIndex }).forEach({ $0.element.titleLabel?.font = self.unenabledFont })
        }
    }
    
    /**
     애니메이션 시간
     */
    public var animateDuration: TimeInterval = 0.6
    
    public var buttons: [UIButton] {
        return self._buttons
    }
    
    private var _selectedIndex: Int?
    private lazy var buttonView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.bottomLineView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            ])
        return view
    }()
    private var bottomLineHeightConstraint: NSLayoutConstraint?
    private var selectedLineHeightConstraint: NSLayoutConstraint?
    private var selectedLineCenterConstraints = [NSLayoutConstraint]()
    
    var _buttons = [UIButton]()
    
    // MARK: Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initVars()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initVars()
    }
    
    // MARK: Method
    
    /// 추가
    public func append(_ button: UIButton) {
        button.addTarget(self, action: #selector(self.buttonTap(_:)), for: .touchUpInside)
        self.removeElements()
        self._buttons.append(button)
        self.redraw()
    }
    
    /// 추가
    public func append(contentsOf: [UIButton]) {
        contentsOf.forEach({ $0.addTarget(self, action: #selector(self.buttonTap(_:)), for: .touchUpInside) })
        self.removeElements()
        self._buttons.append(contentsOf: contentsOf)
        self.redraw()
    }
    
    /// 추가
    public func append(_ buttonText: String) {
        let button = UIButton(type: .system)
        button.setTitle(buttonText, for: .normal)
        button.addTarget(self, action: #selector(self.buttonTap(_:)), for: .touchUpInside)
        self.removeElements()
        self._buttons.append(button)
        self.redraw()
    }
    
    /// 추가
    public func append(contentsOf: [String]) {
        let contentsOf = contentsOf.map { text -> UIButton in
            let button = UIButton(type: .system)
            button.setTitle(text, for: .normal)
            button.addTarget(self, action: #selector(self.buttonTap(_:)), for: .touchUpInside)
            return button
        }
        self.removeElements()
        self._buttons.append(contentsOf: contentsOf)
        self.redraw()
    }
    
    /// 추가
    public func insert(_ button: UIButton, at index: Int) {
        button.addTarget(self, action: #selector(self.buttonTap(_:)), for: .touchUpInside)
        self.removeElements()
        self._buttons.insert(button, at: index)
        self.redraw()
    }
    
    /// 삭제
    @discardableResult
    public func remove(at index: Int) -> UIButton {
        self.removeElements()
        let button = self._buttons.remove(at: index)
        self.redraw()
        return button
    }
    
    /// 삭제
    public func removeAll() {
        self.removeElements()
        self._buttons.removeAll()
        self.redraw()
    }
    
    /// 라인 선택
    public func selectedLine(_ index: Int) {
        self._selectedIndex = index
        self.buttonsUI()
        guard !self.selectedLineCenterConstraints.isEmpty else { return }
        self.selectedLineCenterConstraints.forEach({ $0.priority = UILayoutPriority(250) })
        self.selectedLineCenterConstraints[index].priority = UILayoutPriority(750)
        UIView.animate(withDuration: self.animateDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseIn, animations: {
            self.selectedLineContainerView.layoutIfNeeded()
        })
    }
    
    /// 모든 엘리먼트, 오토레이아웃 삭제
    private func removeElements() {
        self.buttonView.removeConstraints(self.buttonView.constraints)
        self.buttons.forEach({
            $0.removeConstraints($0.constraints)
            $0.removeFromSuperview()
        })
        self.selectedLineContainerView.removeFromSuperview()
        self.selectedLineView.removeFromSuperview()
        self.selectedLineCenterConstraints.removeAll()
    }
    
    /// 다시 그리기
    private func redraw() {
        self._selectedIndex = 0
        self.buttons.forEach({
            $0.setTitleColor(.black, for: .normal)
            self.buttonView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.buttonView.addConstraints([
                NSLayoutConstraint(item: self.buttonView, attribute: .top, relatedBy: .equal, toItem: $0, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.buttonView, attribute: .bottom, relatedBy: .equal, toItem: $0, attribute: .bottom, multiplier: 1, constant: 0)
                ])
        })
        for (index, element) in self.buttons.enumerated() where index != 0 {
            let beforeButton = self.buttons[index - 1]
            self.buttonView.addConstraints([
                NSLayoutConstraint(item: beforeButton, attribute: .width, relatedBy: .equal, toItem: element, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: beforeButton, attribute: .trailing, relatedBy: .equal, toItem: element, attribute: .leading, multiplier: 1, constant: 0)
                ])
        }
        guard let firstButton = self.buttons.first,
            let lastButton = self.buttons.last else { return }
        
        self.buttonView.addConstraint(NSLayoutConstraint(item: self.buttonView, attribute: .leading, relatedBy: .equal, toItem: firstButton, attribute: .leading, multiplier: 1, constant: 0))
        self.buttonView.addConstraint(NSLayoutConstraint(item: self.buttonView, attribute: .trailing, relatedBy: .equal, toItem: lastButton, attribute: .trailing, multiplier: 1, constant: 0))
        
        self.buttonView.addSubview(self.selectedLineContainerView)
        self.selectedLineContainerView.addSubview(self.selectedLineView)
        
        self.buttons.enumerated().forEach({
            let centerConstraint = NSLayoutConstraint(item: $0.element, attribute: .centerX, relatedBy: .equal, toItem: self.selectedLineView, attribute: .centerX, multiplier: 1, constant: 0)
            centerConstraint.priority = UILayoutPriority($0.offset == 0 ? 750 : 250)
            self.selectedLineCenterConstraints.append(centerConstraint)
        })
        self.buttonView.addConstraints(self.selectedLineCenterConstraints)
        
        self.buttonView.addConstraints([
            NSLayoutConstraint(item: firstButton, attribute: .width, relatedBy: .equal, toItem: self.selectedLineView, attribute: .width, multiplier: 1, constant: self.selectedWidthMargin),
            NSLayoutConstraint(item: self.buttonView, attribute: .bottom, relatedBy: .equal, toItem: self.selectedLineContainerView, attribute: .bottom, multiplier: 1, constant: self.selectedBottomMargin),
            NSLayoutConstraint(item: self.buttonView, attribute: .leading, relatedBy: .equal, toItem: self.selectedLineContainerView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.buttonView, attribute: .trailing, relatedBy: .equal, toItem: self.selectedLineContainerView, attribute: .trailing, multiplier: 1, constant: 0)
            ])
        
        self.selectedLineContainerView.addConstraints([
            NSLayoutConstraint(item: self.selectedLineContainerView, attribute: .top, relatedBy: .equal, toItem: self.selectedLineView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.selectedLineContainerView, attribute: .bottom, relatedBy: .equal, toItem: self.selectedLineView, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        
        self.buttonsUI()
    }
    
    private func initVars() {
        self.bottomLineView.backgroundColor = .gray
        self.buttonView.backgroundColor = .clear
        self.selectedLineView.backgroundColor = UIColor.blue
        self.selectedLineContainerView.backgroundColor = .clear
    }
    
    
    @objc private func buttonTap(_ sender: UIButton) {
        var buttonIndex = 0
        for (index, element) in self.buttons.enumerated() {
            if element == sender {
                buttonIndex = index
                break
            }
        }
        if self.delegate?.pageButtonGroupViewButtonIsTap(sender, index: buttonIndex) ?? true {
            self.delegate?.pageButtonGroupViewButtonTap(sender, index: buttonIndex)
        }
    }
    
    private func buttonsUI() {
        guard !self.buttons.isEmpty else { return }
        
        for (index, element) in self.buttons.enumerated() {
            if index == self.selectedIndex {
                if let color = self.enabledColor {
                    self.buttons[index].setTitleColor(color, for: .normal)
                }
                if let font = self.enabledFont {
                    self.buttons[index].titleLabel?.font = font
                }
                self.delegate?.pageButtonGroupViewButtonSelectedButton(element)
            } else {
                if let color = self.unenabledColor {
                    self.buttons[index].setTitleColor(color, for: .normal)
                }
                if let font = self.unenabledFont {
                    self.buttons[index].titleLabel?.font = font
                }
                self.delegate?.pageButtonGroupViewButtonUnselectedButton(element)
            }
        }
    }
}

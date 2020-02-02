//
//  JSONTableView.swift
//  JSONTableView
//
//  Created by cem.olcay on 18/09/2019.
//  Copyright © 2019 cemolcay. All rights reserved.
//

import UIKit
//import SwiftyJSON

open class JSONViewCell: UIView {
    public var title = ""
    public var data: Any? = nil

    public var stackView = UIStackView()
    public var cellStack = UIStackView()
    public var titleLabel = UILabel()
    public var valueLabel = UILabel()
    public var expandButton = UIButton()
    public var expandStack = UIStackView()
    public var bottomLineLayer = CALayer()
    public var canExpand = false
    public var isExpanded = false {
        didSet {
            if isExpanded {
                expand()
            } else {
                collapse()
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  func commonInit() {
    layer.addSublayer(bottomLineLayer)
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
    stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    stackView.addArrangedSubview(cellStack)
    cellStack.translatesAutoresizingMaskIntoConstraints = false
    cellStack.heightAnchor.constraint(equalToConstant: 44).isActive = true
    cellStack.axis = .horizontal
    cellStack.spacing = 8
    let titleStack = UIStackView()
    titleStack.axis = .horizontal
    titleStack.addArrangedSubview(titleLabel)
    titleStack.addArrangedSubview(valueLabel)
    cellStack.addArrangedSubview(titleStack)
    cellStack.addArrangedSubview(expandButton)
    expandButton.translatesAutoresizingMaskIntoConstraints = false
    expandButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
    expandButton.setImage(UIImage(named: "DownToOpen"), for: .normal)
    expandButton.imageView?.contentMode = .scaleAspectFit
    expandButton.addTarget(self, action: #selector(expandButtonDidPress(sender:)), for: .touchUpInside)
    expandButton.tintColor = .lightGray

    titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    stackView.addArrangedSubview(expandStack)
    expandStack.axis = .vertical
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    bottomLineLayer.frame = CGRect(x: 16, y: frame.size.height - 0.5, width: frame.size.width - 16, height: 0.5)
    bottomLineLayer.backgroundColor = UIColor.lightGray.cgColor
  }

    open func reloadData() {
        setup()
        if let validData = data as? JSON {
            switch validData {
            case .Dictionary (let dictData):
                for (key, value) in dictData {
                    let cell = JSONViewCell(frame: .zero)
                    cell.translatesAutoresizingMaskIntoConstraints = false
                    cell.title = key
                    if let dict = value as? [String:AnyObject] {
                        cell.data = JSON.Dictionary(dict)
                    } else if let array = value as? [AnyObject] {
                        cell.data = JSON.Array(array)
                    }
                    cell.reloadData()
                    expandStack.addArrangedSubview(cell)
                    expandButton.isHidden = false
                    expandButton.translatesAutoresizingMaskIntoConstraints = false
                    expandButton.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -8).isActive = true
                    canExpand = true
                }
            case .Array (let arrayData):
                for value in arrayData {
                    valueLabel.text = "\(value)"
                    valueLabel.translatesAutoresizingMaskIntoConstraints = false
                    valueLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor,   constant: -8).isActive = true
                    canExpand = false
                }
            }
        } else if let validData = data as? String {
            valueLabel.text = "\(validData)"
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            valueLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor,   constant: -8).isActive = true
            canExpand = false
        } else if let validData = data as? Int {
            valueLabel.text = "\(validData)"
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            valueLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor,   constant: -8).isActive = true
            canExpand = false
        } else {
            print("Conversion issue 1")
        }
    }
    
    private func setup() {
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.text = title

        valueLabel.font = .systemFont(ofSize: 13, weight: .light)
        valueLabel.text = nil
        valueLabel.numberOfLines = 0
        valueLabel.textAlignment = .right
        valueLabel.minimumScaleFactor = 0.1

        expandButton.isHidden = true
        expandStack.arrangedSubviews.forEach({
            expandStack.removeArrangedSubview($0)
        })
        expandStack.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        expandStack.isHidden = true
    }

    @IBAction func expandButtonDidPress(sender: UIButton) {
        isExpanded = !isExpanded
    }

    public func expand() {
        guard canExpand else { return }
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.expandStack.isHidden = false
                self.expandStack.alpha = 1
                self.stackView.layoutIfNeeded()
                self.expandButton.transform = CGAffineTransform(rotationAngle: .pi)
            },
            completion: nil)
    }

    public func collapse() {
        guard canExpand else { return }
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.expandStack.isHidden = true
                self.expandStack.alpha = 0
                self.stackView.layoutIfNeeded()
                self.expandButton.transform = CGAffineTransform(rotationAngle: 0)
            },
            completion: nil)
    }
}

open class JSONView: UIView {
    
    public var scrollView = UIScrollView()
    
    public var stackView = UIStackView()
    
    public var data: Any? = nil

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }

    open func reloadData() {
        stackView.arrangedSubviews.forEach({ stackView.removeArrangedSubview($0) })
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })

        guard let validData = data as? JSON else {
            print ("no json?")
            return
        }
        switch validData {
        case .Dictionary(let dictData):
            for (key, value) in dictData {
                let cell = JSONViewCell(frame: .zero)
                stackView.addArrangedSubview(cell)
                cell.title = key
                if let dict = value as? [String:AnyObject] {
                    cell.data = JSON.Dictionary(dict)
                } else if let array = value as? [AnyObject] {
                    cell.data = JSON.Array(array)
                } else {
                    cell.data = value
                }
                cell.reloadData()
            }
        case .Array(let arrayData):
            for value in arrayData {
                let cell = JSONViewCell(frame: .zero)
                stackView.addArrangedSubview(cell)
                // cell.title = key
                if let dict = value as? [String:AnyObject] {
                    cell.data = JSON.Dictionary(dict)
                } else if let array = value as? [AnyObject] {
                    cell.data = JSON.Array(array)
                } else {
                    cell.data = value
                }
                cell.reloadData()
            }
        }
        
    }

  public func expandAll() {
    func exp(cell: JSONViewCell) {
      cell.isExpanded = true
      cell.expandStack.arrangedSubviews
        .compactMap({ ($0 as? JSONViewCell) })
        .forEach({ exp(cell: $0) })
    }
    stackView.arrangedSubviews
      .compactMap({ ($0 as? JSONViewCell) })
      .forEach({ exp(cell: $0) })
  }

  public func collapseAll() {
    func coll(cell: JSONViewCell) {
      cell.isExpanded = false
      cell.expandStack.arrangedSubviews
        .compactMap({ ($0 as? JSONViewCell) })
        .forEach({ coll(cell: $0) })
    }
    stackView.arrangedSubviews
      .compactMap({ ($0 as? JSONViewCell) })
      .forEach({ coll(cell: $0) })
  }
}

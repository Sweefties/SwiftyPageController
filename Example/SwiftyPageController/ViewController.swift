//
//  ViewController.swift
//  ContainerControllerTest
//
//  Created by Alexander on 8/2/17.
//  Copyright © 2017 CryptoTicker. All rights reserved.
//

import UIKit
import SwiftyPageController

class ViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl! {
        didSet {
            segmentControl.addUnderlineForSelectedSegment()
        }
    }
    
    var containerController: SwiftyPageController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.addTarget(self, action: #selector(segmentControlDidChange(_:)), for: .valueChanged)
    }
    
    @objc func segmentControlDidChange(_ sender: UISegmentedControl) {
        // change segmented control underline position
        segmentControl.changeUnderlinePosition()
        // select needed controller
        containerController.selectController(atIndex: sender.selectedSegmentIndex, animated: true)
    }
    
    func setupContainerController(_ controller: SwiftyPageController) {
        // assign variable
        containerController = controller
        
        // set delegate
        containerController.delegate = self
        
        // gesture
        containerController.isGestureActive = false
        
        // set animation type
        containerController.animator = .parallax
        
        // set view controllers
        let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(FirstViewController.self)")
        let secondController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(SecondViewController.self)")
        let thirdController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(ThirdViewController.self)")
        containerController.viewControllers = [firstController, secondController, thirdController]
        
        // select needed controller
        containerController.selectController(atIndex: 0, animated: false)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let containerController = segue.destination as? SwiftyPageController {
            setupContainerController(containerController)
        }
    }

    // MARK: - Layout subviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // update underline
        segmentControl.relayoutUnderline()
    }
}

// MARK: - PagesViewControllerDelegate

extension ViewController: SwiftyPageControllerDelegate {
    
    func swiftyPageController(_ controller: SwiftyPageController, alongSideTransitionToController toController: UIViewController) {
        
    }
    
    func swiftyPageController(_ controller: SwiftyPageController, didMoveToController toController: UIViewController) {
        segmentControl.selectedSegmentIndex = containerController.viewControllers.index(of: toController)!
    }
    
    func swiftyPageController(_ controller: SwiftyPageController, willMoveToController toController: UIViewController) {
        
    }
    
}


/// UISegmentedControl Type extension
///
extension UISegmentedControl {
    
    /// remove border
    ///
    /// - Parameters:
    ///     - color: `UIColor`, default is `.white`
    ///     - selectedTextAttributes: `[AnyHashable : Any]?`, default is `nil`
    ///     - normalTextAttributes: `[AnyHashable : Any]?`, default is `nil`
    ///
    func removeBorder(color: UIColor = .white, selectedTextAttributes: [AnyHashable : Any]? = nil, normalTextAttributes: [AnyHashable : Any]? = nil) {
        
        // background image
        let backgroundImage = UIImage.getColoredRectImageWith(color: color.cgColor, andSize: self.bounds.size)
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)
        
        // deviver image
        let deviderImage = UIImage.getColoredRectImageWith(color: color.cgColor, andSize: CGSize(width: 1.0, height: self.bounds.size.height))
        self.setDividerImage(deviderImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        
        // normal title text attributes
        if let attr = normalTextAttributes {
            self.setTitleTextAttributes(attr, for: .normal)
        }
        else{
            self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray], for: .normal)
        }
        // selected title text attributes
        if let attr = selectedTextAttributes {
            self.setTitleTextAttributes(attr, for: .selected)
        }
        else{
            self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: .selected)
        }
    }
    
    /// add underline for selected segment
    ///
    /// - Parameters:
    ///     - height: `CGFloat`, default is 2.0
    ///     - color: `UIColor`, default is `.white`
    ///     - underlineColor: `UIColor`, default is `.black`
    ///     - selectedTextAttributes: `[AnyHashable : Any]?`, default is `nil`
    ///     - normalTextAttributes: `[AnyHashable : Any]?`, default is `nil`
    ///
    func addUnderlineForSelectedSegment(height: CGFloat = 2.0, color: UIColor = .white,  underlineColor: UIColor = .black, selectedTextAttributes: [AnyHashable : Any]? = nil, normalTextAttributes: [AnyHashable : Any]? = nil) {
        
        removeBorder(
            color: color,
            selectedTextAttributes: selectedTextAttributes,
            normalTextAttributes: normalTextAttributes
        )
        
        let underlineWidth: CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = height
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height - 1.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = underlineColor
        underline.tag = 1
        self.addSubview(underline)
        underline.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
    }
    
    /// change underline position
    ///
    /// - Parameter duration: `Double`, default is `0.25`
    ///
    func changeUnderlinePosition(duration: Double = 0.25) {
        guard let underline = self.viewWithTag(1) else {return}
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: duration, animations: {
            underline.frame.origin.x = underlineFinalXPosition
        })
    }
    
    /// relayout underline
    func relayoutUnderline() {
        guard let underline = self.viewWithTag(1) else {return}
        underline.layoutIfNeeded()
    }
}

/// UIImage Type extension
///
extension UIImage {
    
    /// get colored rect image with color and size
    ///
    /// - Parameters:
    ///     - color: `CGColor`
    ///     - size: `CGSize`
    /// - Returns: `UIImage`
    ///
    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        
        guard let rectangleImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        
        return rectangleImage
    }
}

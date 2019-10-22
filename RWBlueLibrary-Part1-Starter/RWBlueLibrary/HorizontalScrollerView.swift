//
//  HorizontalScrollerView.swift
//  RWBlueLibrary
//
//  Created by Berkin Sili on 22.10.2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit

protocol HorizontalScrollerViewDataSource: class {
  // Ask the data source how many views it wants to present inside the horizontal scroller
  func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int
  // Ask the data source to return the view that should appear at <index>
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView
}

protocol HorizontalScrollerViewDelegate: class {
  // inform the delegate that the view at <index> has been selected
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int)
}

class HorizontalScrollerView: UIView {

  weak var dataSource: HorizontalScrollerViewDataSource?
  weak var delegate: HorizontalScrollerViewDelegate?

  // Define a private enum to make it easy to modify the layout at design time. The view’s dimensions inside the scroller will be 100 x 100 with a 10 point margin from its enclosing rectangle.
  private enum ViewConstants {
    static let Padding: CGFloat = 10
    static let Dimensions: CGFloat = 100
    static let Offset: CGFloat = 100
  }
  // Create the scroll view containing the views.
  private let scroller = UIScrollView()
  // Create an array that holds all the album covers.
  private var contentViews = [UIView]()

  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeScrollView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeScrollView()
  }
  
  func initializeScrollView() {
    scroller.delegate = self

    //Adds the UIScrollView instance to the parent view.
    addSubview(scroller)
    
    //Turn off autoresizing masks. This is so you can apply your own constraints
    scroller.translatesAutoresizingMaskIntoConstraints = false
    
    //Apply constraints to the scrollview to completely fill the HorizontalScrollerView
    NSLayoutConstraint.activate([
      scroller.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scroller.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scroller.topAnchor.constraint(equalTo: self.topAnchor),
      scroller.bottomAnchor.constraint(equalTo: self.bottomAnchor)
      ])
    
    //Create a tap gesture recognizer. The tap gesture recognizer detects touches on the scroll view and checks if an album cover has been tapped. If so, it will notify the HorizontalScrollerView delegate.
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollerTapped(gesture:)))
    scroller.addGestureRecognizer(tapRecognizer)
  }
  
  func scrollToView(at index: Int, animated: Bool = true) {
    let centralView = contentViews[index]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
    scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: animated)
  }

  @objc func scrollerTapped(gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: scroller)
    guard
      let index = contentViews.index(where: { $0.frame.contains(location)})
      else { return }
    
    delegate?.horizontalScrollerView(self, didSelectViewAt: index)
    scrollToView(at: index)
  }
  
  func view(at index :Int) -> UIView {
    return contentViews[index]
  }
  
  func reload() {
    // Check if there is a data source, if not there is nothing to load.
    guard let dataSource = dataSource else {
      return
    }
    
    // Remove the old content views
    contentViews.forEach { $0.removeFromSuperview() }
    
    // xValue is the starting point of each view inside the scroller
    var xValue = ViewConstants.Offset
    // Fetch and add the new views
    contentViews = (0..<dataSource.numberOfViews(in: self)).map {
      index in
      // add a view at the right position
      xValue += ViewConstants.Padding
      let view = dataSource.horizontalScrollerView(self, viewAt: index)
      view.frame = CGRect(x: CGFloat(xValue), y: ViewConstants.Padding, width: ViewConstants.Dimensions, height: ViewConstants.Dimensions)
      scroller.addSubview(view)
      xValue += ViewConstants.Dimensions + ViewConstants.Padding
      return view
    }
    // Once all the views are in place, set the content offset for the scroll view to allow the user to scroll through all the albums covers.
    scroller.contentSize = CGSize(width: CGFloat(xValue + ViewConstants.Offset), height: frame.size.height)
  }

  private func centerCurrentView() {
    let centerRect = CGRect(
      origin: CGPoint(x: scroller.bounds.midX - ViewConstants.Padding, y: 0),
      size: CGSize(width: ViewConstants.Padding, height: bounds.height)
    )
    
    guard let selectedIndex = contentViews.index(where: { $0.frame.intersects(centerRect) })
      else { return }
    let centralView = contentViews[selectedIndex]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
    
    scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
    delegate?.horizontalScrollerView(self, didSelectViewAt: selectedIndex)
  }
}

extension HorizontalScrollerView: UIScrollViewDelegate {
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      centerCurrentView()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    centerCurrentView()
  }
}


//
//  FWPopupViewTests.swift
//  FWPopupViewTests
//
//  Created by xfg on 2019/2/13.
//  Copyright © 2019 xfg. All rights reserved.
//

import XCTest
@testable import FWPopupView

class FWPopupViewTests: XCTestCase {
    
    var popupView: FWPopupView!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        popupView = FWPopupView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.5))
        let vProperty = FWPopupViewProperty()
        vProperty.popupCustomAlignment = .topCenter
        vProperty.popupAnimationType = .frame
        vProperty.maskViewColor = UIColor(white: 0, alpha: 0.5)
        vProperty.touchWildToHide = "1"
        vProperty.popupViewEdgeInsets = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        vProperty.animationDuration = 0.2
        popupView.vProperty = vProperty
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        popupView = nil
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testShow() {
        XCTAssertNoThrow(popupView.show())
    }
    
    func testHide() {
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

//
//  FWPopupViewUITests.swift
//  FWPopupViewUITests
//
//  Created by xfg on 2019/2/13.
//  Copyright © 2019 xfg. All rights reserved.
//

import XCTest

class FWPopupViewUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Alert - 单个按钮"]/*[[".cells.staticTexts[\"Alert - 单个按钮\"]",".staticTexts[\"Alert - 单个按钮\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let button = app.buttons["知道了"]
        button.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Alert - 两个按钮"]/*[[".cells.staticTexts[\"Alert - 两个按钮\"]",".staticTexts[\"Alert - 两个按钮\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let button2 = app.buttons["确定"]
        button2.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Alert - 两个按钮（修改参数）"]/*[[".cells.staticTexts[\"Alert - 两个按钮（修改参数）\"]",".staticTexts[\"Alert - 两个按钮（修改参数）\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        button2.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Alert - 多个按钮"]/*[[".cells.staticTexts[\"Alert - 多个按钮\"]",".staticTexts[\"Alert - 多个按钮\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
    }

}

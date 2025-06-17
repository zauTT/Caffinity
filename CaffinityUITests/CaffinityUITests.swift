//
//  CaffinityUITests.swift
//  CaffinityUITests
//
//  Created by Giorgi Zautashvili on 09.06.25.
//

import XCTest

final class CaffinityUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--UITest")
        app.launch()
    }
    
    func testAddingDrinkAddsToDrinks() {
        let app = XCUIApplication()
        app.launch()
        
        let addButton = app.buttons["+ Add Drink"]
        XCTAssert(addButton.waitForExistence(timeout: 3), "add button not found")
        addButton.tap()
        
        let picker = app.pickers.element
        XCTAssert(picker.waitForExistence(timeout: 3), "picker not found")
        
        let pickerWheel = picker.pickerWheels.element(boundBy: 0)
        if pickerWheel.exists {
            pickerWheel.adjust(toPickerWheelValue: pickerWheel.value as? String ?? "")
        }
        
        let selectButton = app.buttons["Select"]
        XCTAssert(selectButton.waitForExistence(timeout: 3), "select button not found")
        selectButton.tap()
        
        let cell = app.tables.cells.element(boundBy: 0)
        XCTAssert(cell.waitForExistence(timeout: 3), "Drink entry not added")
    }
    
    func testDeleteDrink() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        
        app.buttons["+ Add Drink"].tap()
        
        let picker = app.pickers["drinkPicker"]
        XCTAssertTrue(picker.exists)
        picker.pickerWheels.element.adjust(toPickerWheelValue: "Espresso ☕️ (62mg)")
        
        app.buttons["Select"].tap()
        
        let cell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(cell.exists)
        
        cell.swipeLeft()
        cell.buttons["Delete"].tap()
        
        let deletedCell = app.tables.cells.element(boundBy: 0)
        deletedCell.swipeLeft()
        deletedCell.buttons["Delete"].tap()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: deletedCell
        )
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 3)
        XCTAssertEqual(result, .completed, "The cell wasn't deleted in time.")
    }
}

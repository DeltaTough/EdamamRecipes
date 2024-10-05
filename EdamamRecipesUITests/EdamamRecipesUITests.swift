//
//  EdamamRecipesUITests.swift
//  EdamamRecipesUITests
//
//  Created by Dimitrios Tsoumanis on 02/10/2024.
//

import XCTest

final class EdamamRecipesUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testSearchFunctionality() throws {
        let searchBar = app.searchFields["Search recipes by food type"]
        XCTAssertTrue(searchBar.exists, "The search bar should be visible")
        
        searchBar.tap()
        searchBar.typeText("walnut")
        
        app.keyboards.buttons["Search"].tap()
        
        let collectionView = app.collectionViews.element
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: collectionView, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
                XCTAssertGreaterThan(
            collectionView.cells.count,
            0,
            "The collection view should load recipes"
        )
    }
    
    func testSearchWithNoResultsShowsAlert() throws {
        let searchBar = app.searchFields["Search recipes by food type"]
        XCTAssertTrue(searchBar.exists, "The search bar should be visible")
        
        searchBar.tap()
        searchBar.typeText("nldfldflldf")
        
        app.keyboards.buttons["Search"].tap()
        
        let alert = app.alerts.element
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertEqual(
            alert.staticTexts.element.label, 
            "No recipes found. Please type another recipe.",
            "The alert should show the correct message"
        )
        
        alert.buttons["OK"].tap()
    }
}

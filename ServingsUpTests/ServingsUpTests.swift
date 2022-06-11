//
//  ServingsUpTests.swift
//  ServingsUpTests
//
//  Created by Elias Hall on 5/31/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import XCTest
@testable import ServingsUp

class ServingsUpTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCanInitialize() throws -> DishController { //Testing initializing of NavController and DishController
        let bundle = Bundle(for: DishController.self)
        let storyB = UIStoryboard(name: "Main", bundle: bundle)
        let initialVC = storyB.instantiateInitialViewController()
        let tabController = try XCTUnwrap(initialVC as? UITabBarController) //testing tabController
        let navController = try XCTUnwrap(tabController.viewControllers?[0] as? UINavigationController)
        let result = try XCTUnwrap(navController.topViewController as? DishController)
        return result
    }
    
    func testCanInitialize2ndVC() throws -> BookController { //Testing initializing of NavController and BookController
        let bundle = Bundle(for: BookController.self)
        let storyB = UIStoryboard(name: "Main", bundle: bundle)
        let initialVC = storyB.instantiateInitialViewController()
        let tabController = try XCTUnwrap(initialVC as? UITabBarController)
        let navController = try XCTUnwrap(tabController.viewControllers?[1] as? UINavigationController)
        let result = try XCTUnwrap(navController.topViewController as? BookController)
        return result
    }
    
    func testDelegatesDataSources() throws {
        let selfInit = try testCanInitialize() //Testing testCanInitialize
        selfInit.loadViewIfNeeded()
        XCTAssertNotNil(selfInit.tableView.delegate)
        XCTAssertNotNil(selfInit.tableView.dataSource)
        XCTAssertNotNil(selfInit.imagePicker.delegate)
    }
    
    func testDelegatesDataSources2ndVC() throws {
        let selfInit = try testCanInitialize2ndVC() //Testing testCanInitialize
        selfInit.loadViewIfNeeded()
        XCTAssertNotNil(selfInit.tableView.delegate)
        XCTAssertNotNil(selfInit.tableView.dataSource)
        XCTAssertNotNil(selfInit.searchBar.delegate)
    }
    
    
    func testThrowMethods() {
        XCTAssertNoThrow(try Util.excessNameLengthTest(input: ""))
        XCTAssertNoThrow(try Util.excessNameLengthTest(input: "M"))
        XCTAssertNoThrow(try Util.excessNameLengthTest(input: "MMMMMMMMMMMMMMMMMMMMMMMM")) //24 chars
        XCTAssertThrowsError(try Util.excessNameLengthTest(input: "MMMMMMMMMMMMMMMMMMMMMMMMM")) //25 chars
        XCTAssertThrowsError(try Util.excessNameLengthTest(input: "MMMMMMMMMMMMMMMMMMMMMMMMMM")) //26 chars
        
        XCTAssertNoThrow(try Util.emptyStringTest(input: "M"))
        XCTAssertNoThrow(try Util.emptyStringTest(input: "MMM"))
        XCTAssertNoThrow(try Util.emptyStringTest(input: "MMMMMMMMMMMMMMMMMMMMMMMM"))
        XCTAssertThrowsError(try Util.emptyStringTest(input: ""))
    }
    
    func testRemovingTrailingZeroes() {
        XCTAssertEqual(Util.removeTrailingZeros(input: "01000"), "01")
        XCTAssertEqual(Util.removeTrailingZeros(input: "010001"), "010001")
        XCTAssertEqual(Util.removeTrailingZeros(input: "01000.00000"), "01000")
        XCTAssertEqual(Util.removeTrailingZeros(input: "0.0"), "0")
        XCTAssertEqual(Util.removeTrailingZeros(input: "0"), "") //default will be 0
    }
    
    func testCoreDishInitialization() -> CoreDish? {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        guard let context = context else {
            XCTFail()
            return nil
        }
        let coreDish = CoreDish(context: context)
        XCTAssertNotNil(coreDish)
        return coreDish
    }
    
    func testMultiplierPerformance() {
        guard let dish = testCoreDishInitialization() else {
            return
        }
        let dishVM = DishViewModel(dish: dish)
        measure {
        dishVM.multiplyIngredients()
        }
    }
    
    func testSortIngredientsPerformance() {
        guard let dish = testCoreDishInitialization() else {
            return
        }
        let dishVM = DishViewModel(dish: dish)
        measure {
            dishVM.sortIngredients()
        }
    }
}

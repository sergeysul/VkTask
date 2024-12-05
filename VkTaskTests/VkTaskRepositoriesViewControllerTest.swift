import XCTest
@testable import VkTask

class RepositoriesViewControllerTests: XCTestCase {
    
    var viewController: RepositoriesViewController!
    
    override func setUp() {
        super.setUp()

        viewController = RepositoriesViewController()
        _ = viewController.view
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testLabelExists() {
        XCTAssertNotNil(viewController.view.subviews.first { $0 is UILabel }, "Label should exist in the view hierarchy")
    }
    
    func testTableExists() {
        XCTAssertNotNil(viewController.view.subviews.first { $0 is UITableView }, "Table view should exist in the view hierarchy")
    }
}

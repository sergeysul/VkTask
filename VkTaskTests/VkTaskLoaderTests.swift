import XCTest
@testable import VkTask

class MockNetworkClient: NetworkClientProtocol {
    var fetchResult: Result<Data, Error>?
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if let fetchResult = fetchResult {
            handler(fetchResult)
        }
    }
}

class GitHubLoaderTests: XCTestCase {
    func testLoadRepositories_Success() {
        let mockNetworkClient = MockNetworkClient()
        let mockJSON = """
        {
            "items": [
                {
                    "name": "Repo1",
                    "owner": {
                        "login": "Owner1",
                        "avatar_url": "https://example.com/avatar1.png"
                    },
                    "html_url": "https://github.com/Owner1/Repo1"
                },
                {
                    "name": "Repo2",
                    "owner": {
                        "login": "Owner2",
                        "avatar_url": "https://example.com/avatar2.png"
                    },
                    "html_url": "https://github.com/Owner2/Repo2"
                }
            ]
        }
        """

        mockNetworkClient.fetchResult = .success(mockJSON.data(using: .utf8)!)
        
        let loader = GitHubLoader(networkClient: mockNetworkClient)
        let expectation = self.expectation(description: "Repositories loaded")
        
        loader.loadRepositories(for: 1) { result in
            // Then
            switch result {
            case .success(let repositories):
                XCTAssertEqual(repositories.count, 2)
                XCTAssertEqual(repositories[0].name, "Repo1")
                XCTAssertEqual(repositories[1].name, "Repo2")
            case .failure:
                XCTFail("Expected success, got failure instead")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testLoadRepositories_Failure_InvalidJSON() {

        let mockNetworkClient = MockNetworkClient()
        let invalidJSON = "{ invalid json }"
        mockNetworkClient.fetchResult = .success(invalidJSON.data(using: .utf8)!)
        
        let loader = GitHubLoader(networkClient: mockNetworkClient)
        let expectation = self.expectation(description: "Repositories failed to load")
        
        loader.loadRepositories(for: 1) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success instead")
            case .failure(let error):
                XCTAssertTrue(error is DecodingError)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testLoadRepositories_Failure_NetworkError() {

        let mockNetworkClient = MockNetworkClient()
        mockNetworkClient.fetchResult = .failure(NSError(domain: "NetworkError", code: -1, userInfo: nil))
        
        let loader = GitHubLoader(networkClient: mockNetworkClient)
        let expectation = self.expectation(description: "Repositories failed to load")
        
        loader.loadRepositories(for: 1) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success instead")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}


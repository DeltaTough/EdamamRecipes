//
//  APIClientTests.swift
//  EdamamRecipesTests
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import XCTest
@testable import EdamamRecipes

final class APIClientTests: XCTestCase {
    var sut: APIClient!
    var mockSession: MockURLSession!
    var endpoint: Endpoint!
    
    override func setUp() {
        super.setUp()
        let baseURL = URL(string: "https://api.edamam.com/api/recipes/v2")!
        mockSession = MockURLSession()
        sut = APIClient(baseURL: baseURL, session: mockSession)
        endpoint = Endpoint(
            queryItems:
                [URLQueryItem(name: "app_id", value: "9a1d9790"),
                 URLQueryItem(name: "app_key", value: "c89facf9fc50fb3a11d88ae05964d88a"),
                 URLQueryItem(name: "q", value: "walnut"),
                 URLQueryItem(name: "type", value: "public")]
        )
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testFetch_SuccessfulResponse_ReturnsDecodedObject() async throws {
        // Given
        let mockData = """
        {
          "from": 1,
          "to": 20,
          "count": 10000,
          "_links": {
            "next": {
              "href": "https://api.edamam.com/api/recipes/v2?q=walnut&app_key=c89facf9fc50fb3a11d88ae05964d88a&_cont=CHcVQBtNNQphDmgVQntAEX4BYUtxAQUCQWREB2cTZFNyDAoCUXlSBmdBZAd7VQcORGURUGEbawFyBAEHQTFGUTMWZQF7VQQVLnlSVSBMPkd5BgNK&type=public&app_id=9a1d9790",
              "title": "Next page"
            }
          },
          "hits": [
            {
              "recipe": {
                "uri": "http://www.edamam.com/ontologies/edamam.owl#recipe_6e46ebc2e1994dba82f404e9b222ae88",
                "label": "Walnut Crackers Recipe",
                "image": "https://edamam-product-images.s3.amazonaws.com/web-img/b46/b46c269ce3a10fb5ddad8bc11a1e5387.JPG?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEGIaCXVzLWVhc3QtMSJHMEUCID5nExMshR25jk%2FzQyLX7IwbsXOMcNubLeAaU8a%2BiLhGAiEAhktQBqxBo0UZf0%2F6I8rC9uEqBdUFG3AAhAOrw7dgErwqwQUIqv%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARAAGgwxODcwMTcxNTA5ODYiDGFLbkbzNdX9wQYF3yqVBR63LXoNN7Fm9a%2BCw%2BiB43KFU29FeuliNc21tSjPTofLsjIQ9dVjphKRp4fN%2BdqYBpnItvgghX3Dc76LOa4Zqki5IvcOpTljzQegUJbYWwdHv6I73n5OfTsUAJLXkaBN4wgA%2FAesows%2B8uea2UAUiX1SXbT6rtN298y%2FKQ%2B%2FIuDcBAxmt2fb2iDlMMc6Bkpxzw81rk6dsdilCP6v6I%2BvtNlkDxEC%2B7SnFya621Li2uAz%2BHRmJrp%2BZqmmuCgyNA17bBeswoO3hH0ovuWVIHNU87c%2FRtK4MtSR39qPwSX9buYjLSVXTuiuwJWtyoOcilcwcqsSZiwrnZdOtxWWSBaexnVKZ3Xob9P8xR%2FhSHHBknHqGiH%2FDCaRyJlD2gwfKXlzcIVr7Lm5xvXEMQI1WsI8%2B4kbrtoUUAD6DGOtb48p7bEuO0EwTbaZMY3BO09Xx2KO65GuhKP%2FzS%2BA%2FO5mazRkKXWqL6Ey7ZxtrYIuFcidhQ1rl9rXGJY05hdIhyR8i1fo%2BBsg3SCrZazE6u%2BCzXji2XPIGjELhTsfdOgJpPJk1uEfs66IKG%2B9u3uHFzMRiN2haA3TPT7SQJbtCtD52L6jrzrOX8TCrWU36TdtqCYwWwh4CNYOBx2MdKgSvLQop2T0BEXvp7uk3T4lx3Nu0VAQfOMMGq8ao2T%2BI97%2B2NyjM%2BdHN%2FwwwEDsgrUZaTCE4jsDTLI4KOoMELaERcF554JWTn9Z1jCovuZxMHREOPPeGumJ8VWx71E8cia7P3DSRF1toG%2F6fUqumADt5q2zf5%2FBEbz90e74aSRtjwJ0x2JzePBr3x%2BWOWK2ghulPp1SdhwpV%2Bnofmj5nGxJQ%2FTjVL2e4yhupyqCRn9su%2BuAB6SJNs%2Bx%2FIHc3Gkw%2B%2Fv1twY6sQEz5Zg3N3IQV24o%2FLBYI8p2hAHCaGU3hdKZwEwLEKE9CivWzxj04yo3r3tCjSUY3DA2ejL8NL5cPapSCP%2F3sx47sydMXskFBS5G7lB%2Fc5WnPQnoH4yN%2BgAQsBtZ%2Bfudwqiwz1o2kd1ueKCxaj4NV5P9q%2Bi12M%2FFXEjcgtOtwY89AIqImfPmmonOsKjxpcfQdx9kKk2FsnXJIWYBdSCbqkY1h%2F%2FawI%2BXg%2Bg4bvxnL%2BvUGMw%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20241002T180657Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=ASIASXCYXIIFAQGJS37D%2F20241002%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=8c1da03c70c57969a3af4dc8a756e56c1e1e177eec0ac3ae3a4211558cee91e6"
              }
            }
          ]
        }
        """.data(using: .utf8)!
        
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://api.edamam.com/api/recipes/v2?app_id=9a1d9790&app_key=c89facf9fc50fb3a11d88ae05964d88a&q=walnut&type=public")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // When
        let response: WebResponse = try await sut.fetch(endpoint)
        let recipe = response.hits.first?.recipe
        
        // Then
        XCTAssertEqual(recipe?.recipeName, "Walnut Crackers Recipe")
        XCTAssertEqual(recipe?.imageURL.absoluteString, """
                                                       https://edamam-product-images.s3.amazonaws.com/web-img/b46/b46c269ce3a10fb5ddad8bc11a1e5387.JPG?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEGIaCXVzLWVhc3QtMSJHMEUCID5nExMshR25jk%2FzQyLX7IwbsXOMcNubLeAaU8a%2BiLhGAiEAhktQBqxBo0UZf0%2F6I8rC9uEqBdUFG3AAhAOrw7dgErwqwQUIqv%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARAAGgwxODcwMTcxNTA5ODYiDGFLbkbzNdX9wQYF3yqVBR63LXoNN7Fm9a%2BCw%2BiB43KFU29FeuliNc21tSjPTofLsjIQ9dVjphKRp4fN%2BdqYBpnItvgghX3Dc76LOa4Zqki5IvcOpTljzQegUJbYWwdHv6I73n5OfTsUAJLXkaBN4wgA%2FAesows%2B8uea2UAUiX1SXbT6rtN298y%2FKQ%2B%2FIuDcBAxmt2fb2iDlMMc6Bkpxzw81rk6dsdilCP6v6I%2BvtNlkDxEC%2B7SnFya621Li2uAz%2BHRmJrp%2BZqmmuCgyNA17bBeswoO3hH0ovuWVIHNU87c%2FRtK4MtSR39qPwSX9buYjLSVXTuiuwJWtyoOcilcwcqsSZiwrnZdOtxWWSBaexnVKZ3Xob9P8xR%2FhSHHBknHqGiH%2FDCaRyJlD2gwfKXlzcIVr7Lm5xvXEMQI1WsI8%2B4kbrtoUUAD6DGOtb48p7bEuO0EwTbaZMY3BO09Xx2KO65GuhKP%2FzS%2BA%2FO5mazRkKXWqL6Ey7ZxtrYIuFcidhQ1rl9rXGJY05hdIhyR8i1fo%2BBsg3SCrZazE6u%2BCzXji2XPIGjELhTsfdOgJpPJk1uEfs66IKG%2B9u3uHFzMRiN2haA3TPT7SQJbtCtD52L6jrzrOX8TCrWU36TdtqCYwWwh4CNYOBx2MdKgSvLQop2T0BEXvp7uk3T4lx3Nu0VAQfOMMGq8ao2T%2BI97%2B2NyjM%2BdHN%2FwwwEDsgrUZaTCE4jsDTLI4KOoMELaERcF554JWTn9Z1jCovuZxMHREOPPeGumJ8VWx71E8cia7P3DSRF1toG%2F6fUqumADt5q2zf5%2FBEbz90e74aSRtjwJ0x2JzePBr3x%2BWOWK2ghulPp1SdhwpV%2Bnofmj5nGxJQ%2FTjVL2e4yhupyqCRn9su%2BuAB6SJNs%2Bx%2FIHc3Gkw%2B%2Fv1twY6sQEz5Zg3N3IQV24o%2FLBYI8p2hAHCaGU3hdKZwEwLEKE9CivWzxj04yo3r3tCjSUY3DA2ejL8NL5cPapSCP%2F3sx47sydMXskFBS5G7lB%2Fc5WnPQnoH4yN%2BgAQsBtZ%2Bfudwqiwz1o2kd1ueKCxaj4NV5P9q%2Bi12M%2FFXEjcgtOtwY89AIqImfPmmonOsKjxpcfQdx9kKk2FsnXJIWYBdSCbqkY1h%2F%2FawI%2BXg%2Bg4bvxnL%2BvUGMw%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20241002T180657Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=ASIASXCYXIIFAQGJS37D%2F20241002%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=8c1da03c70c57969a3af4dc8a756e56c1e1e177eec0ac3ae3a4211558cee91e6
                                                       """
        )
    }
    
    func testFetch_InvalidResponse_ThrowsError() async {
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(
                string: "https://api.edamam.com/api/recipes/v2?app_id=9a1d9790&app_key=c89facf9fc50fb3a11d88ae05964d88a&q=walnut&type=public")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
        do {
            let _: WebResponse = try await sut.fetch(endpoint)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
            XCTAssertEqual(error as? APIError, .invalidResponse)
        }
    }
    
    func testFetch_InvalidURL_ThrowsError() async {
        let invalidBaseURL = URL(string: "http://example.com:65536")!
        sut = APIClient(baseURL: invalidBaseURL, session: mockSession)
        let endpoint = Endpoint(
            queryItems:
                [URLQueryItem(name: "fail", value: "£@£@£@@£")]
        )
        
        do {
            let _: WebResponse = try await sut.fetch(endpoint)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
            XCTAssertEqual(error as? APIError, .invalidURL)
        }
    }
    
    func testFetch_DecodingError_ThrowsError() async {
        // Given
        let invalidData = "Invalid JSON".data(using: .utf8)!
        mockSession.mockData = invalidData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(
                string: "https://api.edamam.com/api/recipes/v2?app_id=9a1d9790&app_key=c89facf9fc50fb3a11d88ae05964d88a&q=walnut&type=public")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
                
        // When/Then
        do {
            let _: WebResponse = try await sut.fetch(endpoint)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
            if case APIError.decodingError = error {
                // Success
            } else {
                XCTFail("Expected APIError.decodingError, but got \(error)")
            }
        }
    }
}

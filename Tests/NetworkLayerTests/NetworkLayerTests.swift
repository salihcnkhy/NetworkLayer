import XCTest
import Alamofire
import Combine

@testable import NetworkLayer

final class NetworkLayerTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    func testExample() throws {
        let manager = NetworkManager(configuration: .default, interceptor: TestInterceptor(), eventMonitors: [TestEventMonitor()])
        let expectation = expectation(description: "Sink")
        getPublisher(manager: manager).sink { output in
            print(output)
            expectation.fulfill()
        }.store(in: &cancellables)
        waitForExpectations(timeout: 10)
    }
    
    func testExample2() throws {
        let manager = NetworkManager(configuration: .default, interceptor: TestInterceptor(), eventMonitors: [TestEventMonitor()])
        let expectation = expectation(description: "Sink")
        getPublisher2(manager: manager).sink(receiveCompletion: { error in
            print(error)
        }, receiveValue: { (response, server) in
            print(response, server)
            if response == nil && server != nil {
                expectation.fulfill()
            }
        }).store(in: &cancellables)
        waitForExpectations(timeout: 10)
    }

    
    func getPublisher(manager: NetworkManager) -> AnyPublisher<NetworkResponse<SignInResponse, ServerError>, Never> {
        manager.execute(with: GetStockListServiceProvider())
    }
    
    func getPublisher2(manager: NetworkManager) -> AnyPublisher<(SignInResponse?, ServerError?), Error> {
        manager.execute(with: GetStockListServiceProvider())
    }
}

final class TestEventMonitor: EventMonitor {
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        print(request)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print(data)
    }
}

final class TestInterceptor: RequestInterceptor {
    
}

struct ServerError: Decodable {
    let message: String
    let subErrorType: String
    let exceptionType: Int
}

struct SignInResponse: Decodable {
    let isSuccess: Bool
    let userToken: String
}

struct SignInRequest: Encodable {
    let email: String
    let password: String
}

final class GetStockListServiceProvider: ApiServiceProvider<SignInRequest> {
    init() {
        let mockRequest = SignInRequest(email: "test@test.com", password: "123451656")
        super.init(baseUrl: "https://hesabinibil.azurewebsites.net/api", method: .post, path: "/Auth/SignIn", isAuthRequested: false, data: mockRequest)
    }
}

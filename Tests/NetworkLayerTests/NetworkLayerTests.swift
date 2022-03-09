import XCTest
import Alamofire
import Combine
import NetworkEntityLayer

@testable import NetworkLayer

final class NetworkLayerTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    func testExample() throws {
        let manager = NetworkManager(configuration: .default, interceptor: TestInterceptor(), eventMonitors: [TestEventMonitor()])
        let expectation = expectation(description: "Sink")
        getPublisher(manager: manager).sink(receiveCompletion: { error in
            print(error)
            expectation.fulfill()
        }, receiveValue: { (response) in
            print(response)
            expectation.fulfill()
        }).store(in: &cancellables)
        waitForExpectations(timeout: 10)
    }


    func getPublisher(manager: NetworkManager) -> AnyPublisher<SignInResponse, ServerError> {
        manager.execute(with: GetStockListServiceProvider(httpPropertyProvider: MockHttpProperyProvider(), request: SignInRequest(email: "test@test.com", password: "1234565")))
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

final class MockHttpProperyProvider: HttpPropertyProviderProtocol {
    func getBaseUrl() -> String {
        "https://hesabinibil.azurewebsites.net/api"
    }
}

final class TestInterceptor: RequestInterceptor {
    
}

struct ServerError: ServerErrorProtocol {
    init(description: String?) {
        self.init(description: description, message: "", subErrorType: "", exceptionType: 0)
    }
    
    init(description: String? = nil, message: String, subErrorType: String, exceptionType: Int) {
        self.description = description
        self.message = message
        self.subErrorType = subErrorType
        self.exceptionType = exceptionType
    }
    
    var description: String?
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

final class GetStockListServiceProvider: ApiServiceProvider {
    init(httpPropertyProvider: HttpPropertyProviderProtocol, request: SignInRequest) {
        super.init(httpPropertyProvider: httpPropertyProvider, method: .post, path: "/Auth/SignIn", data: request)
    }
}

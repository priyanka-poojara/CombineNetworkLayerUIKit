//
//  Network.swift
//  NetworkCall
//
//  Created by Priyanka on 15/08/23.
//

import Foundation
import Combine

/*
func fetchMovies() -> some Publisher<MovieResponse, Error> {
    let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apikey)")!
    
    return URLSession
        .shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: MovieResponse.self, decoder: jsonDecoder)
}
*/

public class NetworkService {
    
    private init() {}
    
    deinit {
        print("NetworkService Deinit")
    }
    
    public static let main = NetworkService()
   
    public weak var delegate: PNetworkServicesDelegate?
    
    private var observation: NSKeyValueObservation?
    
    private func printResponse(_ response: URLResponse?, _ responseData: Data?) {
        // Your printResponse function remains unchanged.
    }
    
    public func makeApiCall(Service: NetworkURL, HttpMethod: httpMethod, parameters: [String: Any]?, headers: [String: String]?) -> AnyPublisher<([String: Any], Data), NError> {
        return Future { [weak self] promise in
            guard Reachability().isConnected() else {
                promise(.failure(.NetworkError))
                return
            }
            
            let url = Service.Url
            
            guard let URL = URL(string: url) else {
                promise(.failure(.BadUrl))
                return
            }
            
            var request = URLRequest(url: URL)
            
            if let JSONParameters = parameters {
                do {
                    let httpBody = try JSONSerialization.data(withJSONObject: JSONParameters)
                    request.httpBody = httpBody
                } catch {
                    promise(.failure(.BadParams))
                    return
                }
            }
            
            request.httpMethod = HttpMethod.rawValue
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            
            if let header = headers {
                for (key, val) in header {
                    request.setValue(val, forHTTPHeaderField: key)
                }
            }
            
            if let defaultHeaders = PNetDefaultHeaders {
                for (key, val) in defaultHeaders {
                    request.setValue(val, forHTTPHeaderField: key)
                }
            }
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let httpResponse = response as? HTTPURLResponse {
                    self.observation?.invalidate()
                    
                    switch httpResponse.statusCode {
                    case 200, 201, 202, 203:
                        guard let data = data else {
                            promise(.failure(.InvalidResponse))
                            return
                        }
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            
                            if let JSONData = json as? [String: Any] {
                                promise(.success((JSONData, data)))
                            } else {
                                promise(.failure(.InvalidResponse))
                            }
                        } catch {
                            promise(.failure(.InvalidResponse))
                        }
                    case 204:
                        let output: [String: Any] = [
                            "status": "201",
                            "message": "Your input is accepted by the server you were requesting",
                            "MessageBy": "PCombineNetworkServices"
                        ]
                        
                        let dataOfString = "Your input is accepted by the server you were requesting".data(using: .utf16)
                        
                        if let data = dataOfString {
                            promise(.success((output, data)))
                        } else {
                            promise(.failure(.ConversionError))
                        }
                    case 400:
                        promise(.failure(.BadRequest))
                    case 401, 403:
                        promise(.failure(.Forbidden))
                    case 404:
                        promise(.failure(.PageNotFound))
                    case 405:
                        promise(.failure(.invalidMethod))
                    case 500:
                        self.printResponse(response, data)
                        promise(.failure(.ServerError))
                    default:
                        self.printResponse(response, data)
                        promise(.failure(.DefError))
                    }
                } else {
                    self.printResponse(response, data)
                    
                    if let httpError = error as NSError? {
                        print(httpError.localizedDescription)
                        promise(.failure(.BadResponse))
                    } else {
                        promise(.failure(.InvalidResponse))
                    }
                }
            }
            
            self?.observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                DispatchQueue.main.async {
                    self?.delegate?.didProggressed(progress.fractionCompleted)
                }
            }
            
            task.resume()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

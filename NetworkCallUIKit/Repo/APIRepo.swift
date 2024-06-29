//
//  APIRepo.swift
//  NetworkCallUIKit
//
//  Created by Priyanka on 14/09/23.
//

import UIKit
import Combine

class APIRepo {

    private var cancellables = Set<AnyCancellable>()

    func apiGetData(completion: @escaping ((Welcome?, Bool,String) -> Void)) {
        NetworkService.main.makeApiCall(Service: NetworkURL(withURL: "https://api.themoviedb.org/3/movie/upcoming?api_key=da9bc8815fb0fc31d5ef6b3da097a009"), HttpMethod: .get, parameters: nil, headers: nil)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { (response, dataresponse) in
                // Assuming YourResponseModel is Decodable
                if let decodedResponse = try? JSONDecoder().decode(Welcome.self, from: dataresponse) {
                    completion(decodedResponse, true, "Success")
                } else {
                    let decodingError = NSError(domain: "DecodingError", code: 0, userInfo: nil)
                    print("Failed to decode response: \(decodingError)")
                    completion(nil, false, "")
                }
                print(response)
                
            })
            .store(in: &cancellables)
    }
    
}

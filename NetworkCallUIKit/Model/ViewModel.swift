//
//  ViewModel.swift
//  NetworkCallUIKit
//
//  Created by Priyanka on 14/09/23.
//

import Foundation

typealias BindFail = ((_ status: Bool, _ message: String) -> Void)

class ViewModel {
    
    private var failblock: BindFail?
    private lazy var repo: APIRepo? = APIRepo()
    
    var data: Observable<[Welcome]> = .init([])
    
    init(_ bindFailure: @escaping BindFail) {
        self.failblock = bindFailure
    }
    
    func apiGetData(completion: @escaping ((Welcome?, Bool,String) -> Void)) {
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        repo?.apiGetData(completion: { data, status, message in
            completion(data, status, message)
        })
        
    }
    
}

// MARK: Observable
class Observable<T> {
    
    typealias Listener = (T) -> Void
    var listener:Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value:T) {
        self.value = value
    }
    
    func observe( listener:@escaping Listener) {
        self.listener = listener
    }
    
}

/*
 class ViewModel {
     
     private var cancellables: Set<AnyCancellable> = []
     private lazy var repo: APIRepo? = APIRepo()
     
     @Published var data: [Welcome] = []
     
     init() {
         fetchData()
     }
     
     private func fetchData() {
         repo?.apiGetData()
             .sink(receiveCompletion: { completion in
                 switch completion {
                 case .finished:
                     break
                 case .failure(let error):
                     // Handle the error, you can call a failure block or perform some other error handling logic here.
                     print("API Error: \(error)")
                 }
             }, receiveValue: { [weak self] data in
                 self?.data = data
             })
             .store(in: &cancellables)
     }
 }
 */

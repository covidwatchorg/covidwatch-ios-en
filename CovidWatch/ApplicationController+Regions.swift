//
//  Created by Zsombor Szabo on 12/07/2020.
//  
//

import Foundation
import Combine
import os.log
import UIKit

extension ApplicationController {

    func refreshRegions(
        notifyUserOnError: Bool = false
    ) {
        getRegions { (result) in
            switch result {
                case let .success(regions):
//                    print(regions)
                    LocalStore.shared.regions = regions
                    if let index = regions.firstIndex(where: { $0.id == LocalStore.shared.region.id }) {
                        LocalStore.shared.region = regions[index]
                    }
                case let .failure(error):
                    if notifyUserOnError {
                        UIApplication.shared.topViewController?.present(error, animated: true)
                        return
                    }
            }
        }
    }

    func getRegions(
        completion: @escaping (Result<[CodableRegion], Error>) -> Void
    ) {
        os_log(
            "Getting regions ...",
            log: .en
        )

        guard let url = URL(string: Bundle.main.infoDictionary?[.appRegionsJSONURL] as? String ?? "") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTaskPublisher(for: URLRequest(url: url))
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                }
                return element.data
        }
        .decode(type: [CodableRegion].self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .receive(subscriber: Subscribers.Sink(receiveCompletion: { (sinkCompletion) in
            switch sinkCompletion {
                case .failure(let error):
                    os_log(
                        "Getting regions failed=%@...",
                        log: .en,
                        type: .error,
                        error as CVarArg
                    )
                    completion(.failure(error))
                case .finished: ()
            }
        }, receiveValue: { (value) in
            os_log(
                "Got regions count=%d",
                log: .en,
                value.count
            )
            completion(.success(value))
        }))
    }

}

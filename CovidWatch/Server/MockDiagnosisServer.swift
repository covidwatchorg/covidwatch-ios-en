//
//  Created by Zsombor Szabo on 27/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

class MockDiagnosisServer: DiagnosisServer {
    
    private let queue = DispatchQueue(label: "MockDiagnosisServerQueue")

    enum ServerError: Error {
        case cancelled
    }

    private class MockDiagnosisServerTask: ServerTask {
        var isCancelled = false
        let onCancelled: () -> Void
        let queue: DispatchQueue

        init(delay: TimeInterval, queue: DispatchQueue, onSuccess: @escaping () -> Void, onCancelled: @escaping () -> Void) {
            self.onCancelled = onCancelled
            self.queue = queue

            queue.asyncAfter(deadline: .now() + delay) {
                if !self.isCancelled {
                    onSuccess()
                }
            }
        }

        func cancel() {
            queue.async {
                guard !self.isCancelled else { return }

                self.isCancelled = true
                self.onCancelled()
            }
        }
    }

    func fetch(
        since startDate: Date,
        completion: @escaping (Result<[PositiveDiagnosis], Error>) -> Void
    ) -> ServerTask {
        
        let now = Date()
        let entries = generateFakePositiveDiagnoses(from: startDate, to: now)

        return MockDiagnosisServerTask(delay: Double.random(in: 0..<2.5), queue: queue, onSuccess: {
            completion(.success(entries))
        }, onCancelled: {
            completion(.failure(ServerError.cancelled))
        })
    }

    func upload(
        positiveDiagnosis: PositiveDiagnosis,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> ServerTask {
        
        return MockDiagnosisServerTask(delay: Double.random(in: 0..<2.5), queue: queue, onSuccess: {
            completion(.success(()))
        }, onCancelled: {
            completion(.failure(ServerError.cancelled))
        })
    }

}

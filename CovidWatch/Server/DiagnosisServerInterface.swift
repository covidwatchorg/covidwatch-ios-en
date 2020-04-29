import Foundation

public enum DiagnosisServerError: Error {
    case invalidPublicHealthAuthorityPermissionNumber
}

public protocol DiagnosisServer {
    
    @discardableResult
    func fetch(
        since startDate: Date,
        completion: @escaping (Result<[PositiveDiagnosis], Error>) -> Void
    ) -> ServerTask
    
    @discardableResult
    func upload(
        positiveDiagnosis: PositiveDiagnosis,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> ServerTask
}

// A cancellable task.
public protocol ServerTask {
    func cancel()
}

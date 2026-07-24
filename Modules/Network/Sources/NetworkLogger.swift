import Alamofire
import Foundation

final class NetworkLogger: EventMonitor {
    let queue = DispatchQueue(label: "com.network.logger", qos: .background)

    func request<Value>(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Value, AFError>
    ) {
        guard let urlRequest = request.request, let url = urlRequest.url else { return }
        
        let method = urlRequest.httpMethod ?? "UNKNOWN"
        let statusCode = response.response?.statusCode ?? 0
        let duration = response.metrics?.taskInterval.duration ?? 0
        
        print("🌐 ------------------ NETWORK LOG ------------------")
        print("➡️ Request: [\(method)] \(url.absoluteString)")
        
        if let headers = urlRequest.allHTTPHeaderFields, !headers.isEmpty {
            print("📋 Headers: \(headers)")
        }
        
        // Pretty log the outgoing body
        if let httpBody = urlRequest.httpBody, let prettyBody = prettyPrintedJSON(from: httpBody) {
            print("📤 Outgoing Body:\n\(prettyBody)")
        }
        
        print("⬅️ Response Status: \(statusCode) | Time: \(String(format: "%.3f", duration))s")
        
        // Pretty log the incoming response body
        if let data = response.data, let prettyResponse = prettyPrintedJSON(from: data) {
            print("📦 Response Body:\n\(prettyResponse)")
        }
        
        if let error = response.error {
            print("❌ Error: \(error.localizedDescription)")
        }
        print("---------------------------------------------------\n")
    }
    
    // MARK: - Helpers
    
    /// Converts raw Data into a pretty-printed JSON string.
    private func prettyPrintedJSON(from data: Data) -> String? {
        do {
            // 1. Try to serialize the data into a JSON object
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            // 2. Convert it back to Data, but this time with the .prettyPrinted option
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .withoutEscapingSlashes])
            
            // 3. Return as a String
            return String(data: prettyData, encoding: .utf8)
        } catch {
            // Fallback: If it's not valid JSON (like an HTML error page or plain text), just print the raw string
            return String(data: data, encoding: .utf8)
        }
    }
}

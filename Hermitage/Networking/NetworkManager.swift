//
//  NetworkManager.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

class NetworkManager {

    // MARK: - Constants

    static let shared = NetworkManager()

    // MARK: - Inits

    private init () { }

    // MARL: - Requests
    func request(_ url: String, parameters: [String: String], completion: @escaping (ServerResponseJSON?, Error?) -> Void ) {
        guard var components = URLComponents(string: url) else {
            return
        }
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        guard let url = components.url else {
            return
        }
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                    completion(nil, error)
                    return
            }

            let responseJSON = try? JSONDecoder().decode(ServerResponseJSON.self, from: data)
            completion(responseJSON, nil)
        }
        task.resume()
    }
}

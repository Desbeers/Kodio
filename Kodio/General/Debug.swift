//
//  Debug.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

extension Thread {
    class func printCurrent() {
        print("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}

@discardableResult
func measure<A>(name: String = "", _ block: () -> A) -> A {
    let startTime = CACurrentMediaTime()
    let result = block()
    let timeElapsed = CACurrentMediaTime() - startTime
    print("Time: \(name) - \(timeElapsed)")
    return result
}

// class InstanceTracker {
//    static var count: Int {
//        counter += 1
//        return counter
//    }
//    let instance = InstanceTracker.count
//    let name: String
//    private static var counter: Int = 0
//    private static var indent: Int = 0
//    init(_ name: String) {
//        self.name = name
//        self("\(name).init() #\(instance)")
//    }
//    deinit {
//        self("\(name).deinit() #\(instance)")
//    }
//    func callAsFunction<Result>(_ message: String? = nil, _ result: () -> Result) -> Result {
//        self("\(name).body #\(instance) {")
//        Self.indent += 2
//        if let message = message {
//            self(message)
//        }
//        defer {
//            Self.indent -= 2
//            self("}")
//        }
//        return result()
//    }
//    func callAsFunction(_ string: String) {
//         // print(String(repeating: " ", count: Self.indent) + string)
//    }
// }

/// Tracker usage example

// struct ViewSongs: View {
//    let tracker = InstanceTracker("ViewSongs")
//    var body: some View {
//        tracker {
//            Text("Tracker!")
//            .onAppear {
//                tracker("ViewSongs onAppear")
//            }
//            .onChange(of: library.filteredSongs) { _ in
//                tracker("ViewSongs onChange")
//            }
//        }
//    }
// }

func logger(_ string: String) {
    print("\(string) \(Date())")
}

/// Print raw JSON to the console
func debugJsonResponse(data: Data) {
    do {
        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
            print(jsonResult)
        }
    } catch let error {
        print(error.localizedDescription)
    }
}

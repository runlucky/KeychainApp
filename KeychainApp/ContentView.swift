//
//  ContentView.swift
//  KeychainApp
//
//  Created by Kakeru Fukuda on 2021/10/04.
//

import SwiftUI

struct ContentView: View {
    @State private var key = ""
    @State private var value = ""
    @State private var description = ""

    private let storage: Storage = KeychainStorage()

    var body: some View {
        VStack(alignment: .center) {
            TextField("key", text: $key)
                .padding(10)
                .frame(width: 200, height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            TextField("value", text: $value)
                .padding(10)
                .frame(width: 200, height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(10)

            HStack {
                Button("保存") {
                    do {
                        try storage.save(key: key, value: value)
                        description = "保存しました"
                    } catch {
                        description = error.localizedDescription
                    }
                }
                .frame(width: 100, height: 40)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)

                Button("読み込み") {
                    do {
                        value = try storage.load(key: key, type: String.self)
                        description = "読み込みました"
                    } catch {
                        description = error.localizedDescription
                    }
                }
                .frame(width: 100, height: 40)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)

            }
            
            Text(description)

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

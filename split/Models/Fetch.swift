//
//  Fetch.swift
//  split
//
//  Created by Jacob Tepperman on 2021-05-25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class Fetch: ObservableObject {
    @Published var houses = [House]()
    private var db = Firestore.firestore()
    
    func fetchData() {
        db.collection("houses").addSnapshotListener{ (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no documents")
                return
            }
            self.houses = documents.map { queryDocumentSnapshot -> House in
                let data = queryDocumentSnapshot.data()
                
                let id = queryDocumentSnapshot.documentID
                let name = data["name"] as? String ?? ""
                let members = data["members"] as? [String] ?? [String]()
                
                return House(id: id, name: name, members: members)
            }
        }
    }
    
    func updateHouses( h: Binding<[House]>) {
        db.collection("houses").addSnapshotListener{ (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no documents")
                return
            }
            print(querySnapshot!.documents.first!.data())
            h.wrappedValue = documents.map { queryDocumentSnapshot -> House in
                let data = queryDocumentSnapshot.data()
                
                let id = queryDocumentSnapshot.documentID
                let name = data["name"] as? String ?? ""
                let members = data["members"] as? [String] ?? [String]()
                let password = data["password"] as? String ?? ""
                
                return House(id: id, name: name, members: members, password: password)
            }
        }
    }
}

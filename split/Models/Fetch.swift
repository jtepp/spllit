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
    private var db = Firestore.firestore()
    
    func getHouse (h: Binding<House>, id: String) {
        db.document("houses/"+id).addSnapshotListener { (querySnapshot, error) in
            guard let doc = querySnapshot else {
                print("no house by id %s", id)
                return
            }
            let data = doc.data()
            let name = data?["name"] as? String ?? ""
            
            let password = data?["password"] as? String ?? ""
            
            h.wrappedValue = House(id: id, name: name, members: h.wrappedValue.members, payments: h.wrappedValue.payments, password: password)
            
            self.getMembers(h: h, id: id)
            
            self.getPayments(h: h, id: id)
            
        }
    }
    
    func getMembers(h: Binding<House>, id: String) {
        db.collection("houses/"+id+"/members").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no house by id %s, or maybe no members..?", id)
                return
            }
            
            h.wrappedValue.members = documents.map({ q -> Member in
                let data = q.data()
                
                let name = data["name"] as? String ?? ""
                let owesMe = data["owesMe"] as? [String : Float] ?? [String : Float]()
                let iOwe = data["iOwe"] as? [String : Float] ?? [String : Float]()
                let image = data["image"] as? String ?? ""
                let admin = data["admin"] as? Bool ?? false
                
                return Member(id: q.documentID, name: name, owesMe: owesMe, iOwe: iOwe, image: image, admin: admin)
            })
        }
    }
    
    func getPayments(h: Binding<House>, id: String) {
        db.collection("houses/"+id+"/payments").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no house by id %s, or maybe no payments..?", id)
                return
            }
            
            h.wrappedValue.payments = documents.map({ q -> Payment in
                let data = q.data()
                
                let to = data["to"] as? String ?? ""
                let time = data["time"] as? NSNumber ?? 0
                let from = data["from"] as? String ?? ""
                let reqfrom = data["reqfrom"] as? [String] ?? [""]
                let amount = data["amount"] as? NSNumber ?? 0
                let memo = data["memo"] as? String ?? ""
                let isRequest = data["isRequest"] as? Bool ?? false
                let by = data["by"] as? String ?? ""
                
                return Payment(id: q.documentID, to: to, from: from, reqfrom: reqfrom, amount: Float(truncating: amount), time: Int(truncating: time), memo: memo, isRequest: isRequest, by: by)
            })
        }
    }
    
    func updateImg(img: UIImage, hId: String, myId: String) {
        db.document("houses/\(hId)/members/\(myId)").updateData(["image":imgtob64(img: img.resized(toWidth: 400)!)])
    }
    
    func sendPayment(p: Payment, h: House) {
//        let pId =
            db.collection("houses/\(h.id)/payments").addDocument(data:
                                                                        ["amount":p.amount, "from":p.from, "reqfrom":p.reqfrom, "isRequest":p.isRequest, "to":p.to, "time":p.time, "memo":p.memo, "by":UserDefaults.standard.string(forKey: "myId") ?? "noID"]
        )
//            .documentID
        
        
    }
    
    
    //iterate through every member
    //if in reqfrom, balance goes down (u owe)
    //if in from, balance goes up (u sent)
    
    //array for owe, array for sent - each member by index
    //if indices dont cancel, you owe
    
    
    //array for to in isRequest (u asked)
    //array for to in payment (u were paid)
    //if indices dont cancel, you are owed
    
    
    func updateBalances(h: House, m: Member) {
        var owesMe = [String:Float]()
        var iOwe = [String:Float]()
        
        for payment in h.payments {
            if payment.isRequest {
                if payment.to == m.name {
                    
                }
            } else {
                
            }
        }
        
        
    }
    
    
    func deletePayment(p: Payment, h: House) {
        db.document("houses/\(h.id)/payments/\(p.id!)").delete()
    }
    
}

func idfromnamehouse(name: String, house: House) -> String {
    return house.members.first { (m) -> Bool in
        return m.name == name
    }?.id ?? ""
}

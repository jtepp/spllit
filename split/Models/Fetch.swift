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
    
    func getHouse (h: Binding<House>, inWR: Binding<Bool>, noProf: Binding<Bool>) {
        if (UserDefaults.standard.string(forKey: "houseId") ?? "") != ""
        {
            let id = UserDefaults.standard.string(forKey: "houseId") ?? ""
            let myId = UserDefaults.standard.string(forKey: "myId") ?? ""
            
            print("ID:    \(id)")
            print("ME:    \(myId)")
            print("H:     \(h.wrappedValue.members.count)")
            
            if id != "" && id != "waitingRoom" { // has real house id
                print("has real hid \(id) \(myId)")
                inWR.wrappedValue = false
                noProf.wrappedValue = false
                
                
                
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
                    
                    let t = UserDefaults.standard.string(forKey: "fcm") ?? ""
                    
                    if t != "" {
                        self.placeToken(h: h, id: myId, token: t)
                    }
                    
                    if h.wrappedValue.members.first(where: { (m) -> Bool in
                        return m.id == UserDefaults.standard.string(forKey: "myId")
                    }) == nil && !h.wrappedValue.members.isEmpty && h.wrappedValue.id != "" { //if u dont exist in the house and its not just empty
                        //if ur an alien, go to void, otherwise get waitingRoomed
                        if myId == "" {
                            print("gotovoid")
                            UserDefaults.standard.set("", forKey: "houseId")
                            noProf.wrappedValue = true
                            inWR.wrappedValue = true
                            h.wrappedValue = .empty
                        } else {
                            print("wred")
//                            UserDefaults.standard.set("waitingRoom", forKey: "houseId")
//                            noProf.wrappedValue = false
//                            h.wrappedValue = .empty
//                            inWR.wrappedValue = true
                        }
                    }
                    
                }
            }
            //        else if id == "waitingRoom" && myId != "" { //in waiting room and account exists
            //            print("in waiting room and account exists")
            //            inWR.wrappedValue = true
            //            noProf.wrappedValue = false
            //            db.document("waitingRoom/"+myId).addSnapshotListener { (querySnapshot, error) in
            //                guard let doc = querySnapshot?.data() else {
            //                    //                    print("asfasdfjkasd \(error!)")
            //
            ////                    inWR.wrappedValue = true
            ////                    noProf.wrappedValue = true
            //
            //                    //                    //set id bound and ud to ""
            //                    //                    if h.wrappedValue.members.first(where: { (m) -> Bool in
            //                    //                        return m.id == UserDefaults.standard.string(forKey: "myId")
            //                    //                    }) == nil && !h.wrappedValue.members.isEmpty && h.wrappedValue.id != "" { //if u dont exist in the house and its not just empty
            //                    //                        //if ur an alien, go to void, otherwise get waitingRoomed
            //                    //                        if myId == "" {
            //                    //                            UserDefaults.standard.set("", forKey: "houseId")
            //                    //                            noProf.wrappedValue = true
            //                    //                        } else {
            //                    //                            UserDefaults.standard.set("waitingRoom", forKey: "houseId")
            //                    //                            noProf.wrappedValue = false
            //                    //                        }
            //                    //                        inWR.wrappedValue = true
            //                    //                    }
            //
            //                    return
            //                }
            //                let data = doc
            //                print(data)
            //                var e = House.empty
            //                let newMember = Member(id: myId, home: "waitingRoom", name: (data["name"] ?? "") as! String, image: (data["image"] ?? "") as! String)
            //                e.members = [newMember]
            //                h.wrappedValue = e //empty house
            //
            //            }
            //        } else if id == "waitingRoom" && myId == "" {
            //            print("get out of waiting room alien")
            //            inWR.wrappedValue = true
            //            noProf.wrappedValue = true
            //            UserDefaults.standard.set("", forKey: "houseId") //get out of waiting room alien
            //        } else if id == "" {
            //            print("where u belong")
            //            UserDefaults.standard.set("", forKey: "houseId")
            //            inWR.wrappedValue = true
            //            noProf.wrappedValue = true
            //        }
        }}
    
    func getMembers(h: Binding<House>, id: String) {
        db.collection("houses/"+id+"/members").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no house by id %s, or maybe no members..?", id)
                return
            }
            
            h.wrappedValue.members = documents.map({ q -> Member in
                let data = q.data()
                
                let name = data["name"] as? String ?? ""
                let home = data["home"] as? String ?? ""
                let owesMe = data["owesMe"] as? [String : Float] ?? [String : Float]()
                let iOwe = data["iOwe"] as? [String : Float] ?? [String : Float]()
                let image = data["image"] as? String ?? ""
                let admin = data["admin"] as? Bool ?? false
                let showStatus = data["showStatus"] as? Bool ?? true
                let online = data["online"] as? Bool ?? false
                let lastSeen = data["lastSeen"] as? NSNumber ?? 0
//                print("DFSSSS: \(name) \(data["lastSeen"])")
                return Member(id: q.documentID, home: home, name: name, owesMe: owesMe, iOwe: iOwe, image: image, admin: admin, showStatus: showStatus, online: online, lastSeen: lastSeen)
            })
            for member in h.wrappedValue.members {
                self.updateBalances(h: h.wrappedValue, m: member)
            }
        }
    }
    
    //    func updateMember(m: Binding<Member>) {
    //        let hid = UserDefaults.standard.string(forKey: "houseId")
    //        db.document("houses/\(hid)/members/\(m.wrappedValue.id)").addSnapshotListener { (documentSnapshot, err) in
    //            guard let data = documentSnapshot?.data() else {
    //                print("dsfasddasfasd;flj")
    //                return
    //            }
    //            let name = data["name"] as? String ?? ""
    //            let home = data["home"] as? String ?? ""
    //            let owesMe = data["owesMe"] as? [String : Float] ?? [String : Float]()
    //            let iOwe = data["iOwe"] as? [String : Float] ?? [String : Float]()
    //            let image = data["image"] as? String ?? ""
    //            let admin = data["admin"] as? Bool ?? false
    //
    //            m.wrappedValue.name = name
    //            m.wrappedValue.home = home
    //            m.wrappedValue.owesMe = owesMe
    //            m.wrappedValue.iOwe = iOwe
    //            m.wrappedValue.image = image
    //            m.wrappedValue.admin = admin
    //        }
    //    }
    //
    
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
                let isAn = data["isAn"] as? Bool ?? false
                let by = data["by"] as? String ?? ""
                
                return Payment(id: q.documentID, to: to, from: from, reqfrom: reqfrom, amount: Float(truncating: amount), time: Int(truncating: time), memo: memo, isRequest: isRequest, isAn: isAn, by: by)
            })
            for member in h.wrappedValue.members {
                self.updateBalances(h: h.wrappedValue, m: member)
            }
        }
    }
    
    func updateImg(img: UIImage, hId: String, myId: String) {
        let id = UserDefaults.standard.string(forKey: "myId")
        print("UPDATEIMG")
        db.document("houses/\(hId)/members/\(id ?? "EMPTYIMG")").updateData(["image":imgtob64(img: img.resized(toWidth: 400)!)])
    }
    
    func sendPayment(p: Payment, h: House) {
        db.collection("houses/\(h.id)/members").getDocuments { querySnapshot, err in
            guard let docs = querySnapshot?.documents else {
                print(err.debugDescription)
                return
            }
            var fcms = [String]()
            if p.isAn {
                docs.forEach { qds in
                    let d = qds.data()
                    let f = d["fcm"] as? String ?? ""
                    if f != "" {
                        fcms.append(f)
                    }
                }
                
            } else if p.isRequest {
                docs.forEach { qds in
                    let d = qds.data()
                    let f = d["fcm"] as? String ?? ""
                    let n = d["name"] as? String ?? ""
                    if f != "" && p.reqfrom.contains(n) {
                        fcms.append(f)
                    }
                }
                
            } else {
                docs.forEach { qds in
                    let d = qds.data()
                    let f = d["fcm"] as? String ?? ""
                    let n = d["name"] as? String ?? ""
                    if f != "" && p.to == n {
                        fcms.append(f)
                    }
                }
                
            }
            
            
            
            
            self.db.collection("houses/\(h.id)/payments").addDocument(data:
                                                                        ["amount":p.amount, "from":p.from, "reqfrom":p.reqfrom, "isRequest":p.isRequest, "to":p.to, "time":p.time, "memo":p.memo, "by":UserDefaults.standard.string(forKey: "myId") ?? "noID", "isAn":p.isAn, "fcm":fcms]
            )
            //            .documentID
            for member in h.members {
                self.updateBalances(h: h, m: member)
            }
        }
        
        
    }
    
    
    func updateBalances(h: House, m: Member) {
        if (UserDefaults.standard.string(forKey: "houseId") ?? "") != "" {
            //            print("\n\n\(UserDefaults.standard.string(forKey: "houseId"))\n\nYAYBAL\n\n\(h.payments)\n")
            var owesMe = [String:Float]()
            var iOwe = [String:Float]()
            //            for member in h.members {
            //                owesMe[member.name] = 0
            //                iOwe[member.name] = 0
            //            }
            
            for payment in h.payments
                .filter({ (p) -> Bool in //iterate thru all payments
                    return !p.isAn //exclude announcments
                })
            {
                if payment.isRequest {
                    print("WASREQ\(payment)")
                    if payment.to == m.name {
                        for member in payment.reqfrom {
                            //they owe me from my request
                            if (owesMe[member] ?? 0) == 0 {
                                owesMe[member] = payment.amount / Float(payment.reqfrom.count)
                            } else {
                                owesMe[member]! += payment.amount / Float(payment.reqfrom.count)
                            }
                        }
                    } else if payment.reqfrom.contains(m.name) {
                        //i owe them from their request
                        if (iOwe[payment.to] ?? 0) == 0 {
                            iOwe[payment.to] = payment.amount / Float(payment.reqfrom.count)
                        } else {
                            iOwe[payment.to]! += payment.amount / Float(payment.reqfrom.count)
                        }
                    }
                } else { //its a payment
                    print("WASPAY\(payment)")
                    if payment.to == m.name {
                        //paid to me
                        if (owesMe[payment.from] ?? 0) == 0 {
                            owesMe[payment.from] =  -payment.amount //they owe me less now
                        } else {
                            owesMe[payment.from]! -=  payment.amount //they owe me less now
                        }
                    } else if payment.from == m.name {
                        //i paid them
                        if (iOwe[payment.to] ?? 0) == 0 {
                            iOwe[payment.to] = -payment.amount//i owe them less now
                        } else {
                            iOwe[payment.to]! -= payment.amount//i owe them less now
                        }
                    }
                }
            }
            //        let id = UserDefaults.standard.string(forKey: "myId")
//            print("\n\nowes\(owesMe)\n\n\n\(iOwe)\niown")
            iOwe.forEach { (key: String, value: Float) in
                if abs(value - (owesMe[key] ?? Float(0))) < 0.01 {
                    iOwe[key] = 0
                    owesMe[key] = 0
                }
            }
            db.document("houses/\(UserDefaults.standard.string(forKey: "houseId") ?? "BADHOUSEUPDATEBAL")/members/\(m.id)").updateData(["owesMe":owesMe, "iOwe":iOwe])
            
        } else {
            print("\n\n\(UserDefaults.standard.string(forKey: "houseId") ?? "HEREEOVERHER")\n\nBALBALBALBAL\n")
        }
    }
    
    
    func deletePayment(p: Payment, h: House) {
        db.document("houses/\(h.id)/payments/\(p.id!)").delete()
        for member in h.members {
            self.updateBalances(h: h, m: member)
        }
    }
    
    func removeMember(m: Member, h: Binding<House>) {
        if (UserDefaults.standard.string(forKey: "houseId") ?? "") != "" {
            let docRef = db.document("houses/\(UserDefaults.standard.string(forKey: "houseId") ?? "BADHOUSERMMEMBER")/members/\(m.id)")
            docRef.getDocument { (documentSnapshot, err) in
                guard let doc = documentSnapshot else {
                    print("couldn't get doc \(String(describing: err))")
                    return
                }
                self.db.document("waitingRoom/\(m.id)").setData(doc.data()!)
                self.db.document("waitingRoom/\(m.id)").updateData(["iOwe" : [String:Float](), "owesMe": [String:Float]()], completion: { (err) in
                    self.db.collection("houses/\(h.wrappedValue.id)/payments").getDocuments { (querySnapshot, err) in
                        guard let documents = querySnapshot?.documents else {
                            print("remove member no payments or something")
                            return
                        }
                        for doc in documents.filter({ (doc) -> Bool in
                            let d = doc.data()
                            let to = (d["to"] ?? "") as! String
                            let from = (d["from"] ?? "") as! String
                            let reqfrom = (d["reqfrom"] ?? [""]) as! [String]
                            let isAn = d["isAn"] as? Bool ?? false
                            return (to.contains(m.name) || from.contains(m.name) || reqfrom.contains(m.name)) && !isAn
                        }) {
                            self.db.document("houses/\(h.wrappedValue.id)/payments/\(doc.documentID)").delete()
                            h.wrappedValue.members.removeAll { (m) -> Bool in
                                return m.id == doc.documentID
                            }
                        }
                    }
                    docRef.delete()
                    self.sendPayment(p: Payment(from: m.name, time: Int(NSDate().timeIntervalSince1970), memo: "was removed from the group", isAn: true), h: h.wrappedValue)
                })
            }
            
        }}
    func swapAdmin(m:Member, h:House){
        db.collection("houses/"+h.id+"/members").getDocuments{ (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no house by id %s, or maybe no members..?", h.id)
                return
            }
            documents.forEach { (doc) in
                let id = doc.documentID
                self.db.document("houses/\(h.id)/members/\(id)").updateData(["admin": id == m.id ? true : false])
                if m.id == id {
                    self.sendPayment(p: Payment(from: m.name, time: Int(NSDate().timeIntervalSince1970), memo: "was made the Group Admin", isAn: true), h: h)
                }
            }
        }
    }
    func addToWR(m: Binding<Member>, myId: Binding<String>, h: Binding<House>){
        db.collection("waitingRoom").addDocument(data: ["name":m.wrappedValue.name, "image":m.wrappedValue.image]).getDocument { (documentSnapshot, err) in
            UserDefaults.standard.set(documentSnapshot?.documentID ?? "", forKey: "myId")
            myId.wrappedValue = documentSnapshot?.documentID ?? ""
            m.wrappedValue.id = documentSnapshot?.documentID ?? "addtowrerror"
            m.wrappedValue.home = "waitingRoom"
            h.members.wrappedValue.append(m.wrappedValue)
            
        }
        UserDefaults.standard.set("waitingRoom", forKey: "houseId")
        
        
    }
    
    func switchToHouse(h: Binding<House>, m: Binding<Member>, newGroup: String, newPass: String, showAlert: Binding<Bool>, tapped: Binding<Bool>, msg: Binding<String>, inWR: Binding<Bool>, noProf: Binding<Bool>, showInvite: Binding<Bool>, deleteFromHere: String = "", killHouse: Bool = false) {
        var house = House.empty.id
        let startHouse = h.wrappedValue
        db.collection("houses").getDocuments { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print(err.debugDescription)
                return
            }
            
            documents.forEach { (doc) in
                if doc.documentID == newGroup {
                    house = doc.documentID
                    let d = doc.data()
                    let p = (d["password"] ?? "") as! String
                    
                    if newPass == p {
                        //add this member to house, remove from wr set userdefaults and call for a refresh
                        let mm = m.wrappedValue
                        print("mm \(mm)")
                        print("house \(house)")
                        print("hid \(doc.documentID)")
                        print("mid switching \(mm.id)")
                        UserDefaults.standard.set(mm.id, forKey: "myId")
                        
                            
                            self.db.collection("houses/\(house)/members/").getDocuments { querySnapshot, err in
                                guard let docs = querySnapshot?.documents else {
                                    print(err.debugDescription)
                                    return
                                }
                                if !docs.contains(where: { doc in
                                    let data = doc.data()
                                    let name = data["name"] ?? ""
                                    return name as! String == m.wrappedValue.name
                                    
                                }) {
                                    //
                                    self.db.document("houses/\(doc.documentID)/members/\("\(m.wrappedValue.id)")").setData(["name" : mm.name, "image" : mm.image, "home" : doc.documentID, "showStatus": mm.showStatus]) { _ in
                                        h.wrappedValue.id = doc.documentID
                                        h.wrappedValue.members.append(m.wrappedValue)
                                        UserDefaults.standard.set(mm.id, forKey: "myId")
                                        print("ISTHISIT \(doc.documentID)")
                                        UserDefaults.standard.set(doc.documentID, forKey: "houseId")
                                        inWR.wrappedValue = false
                                        if deleteFromHere != "" {
                                            var mem = Member.empty
                                            mem.id = mm.id
                                            mem.name = mm.name
                                            mem.home = startHouse.id
                                            self.deleteAccount(m: .constant(mem), erase: startHouse.members.count == 1, inWR: .constant(false), transfer: true)
                                        } else {
                                            self.db.document("waitingRoom/\(mm.id)").delete()
                                        }
                                        self.sendPayment(p: Payment(from: mm.name, time: Int(NSDate().timeIntervalSince1970), memo: "joined the group", isAn: true), h: House(id: doc.documentID, name: "", members: [Member](), payments: [Payment](), password: ""))
                                        if killHouse {
//                                            self.db.document("houses/\(h.documentID)").delete()
                                        }
                                        self.getHouse(h: h, inWR: inWR, noProf: noProf)
                                        showInvite.wrappedValue = false
                                    }
                                    //
                                    
                                } else {
                                    showAlert.wrappedValue = true
                                    tapped.wrappedValue = false
                                    msg.wrappedValue = "Member already exists by that name"
                                }
                                
                            }
                            
                            
                        
                    } else {
                        showAlert.wrappedValue = true
                        tapped.wrappedValue = false
                        msg.wrappedValue = "Incorrect password"
                    }
                    
                }
            }
//            if house == House.empty.id {
//                showAlert.wrappedValue = true
//                tapped.wrappedValue = false
//                msg.wrappedValue = "Group not found"
//            }
            tapped.wrappedValue = false
        }
        
    }
    
    func joinHouse(hh: Binding<House>, m: Binding<Member>, hId: String, password: String, showAlert: Binding<Bool>, tapped: Binding<Bool>, msg: Binding<String>, inWR: Binding<Bool>, forceAdmin: Bool = false, deleteFromHere: String = "", killHouse: Bool = false) {
        var house = House.empty.id
        let startHouseID = hh.wrappedValue.id
        db.collection("houses").getDocuments { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print(err.debugDescription)
                return
            }
            
            documents.forEach { (h) in
                if h.documentID == hId {
                    house = h.documentID
                    let d = h.data()
                    let p = (d["password"] ?? "") as! String
                    
                    if password == p {
                        //add this member to house, remove from wr set userdefaults and call for a refresh
                        let mm = m.wrappedValue
                        print("mm \(mm)")
                        print("house \(house)")
                        print("hid \(h.documentID)")
                        print("mid joining \(mm.id)")
                        UserDefaults.standard.set(mm.id, forKey: "myId")
                        
                        if mm.id == "" {
                            m.wrappedValue = .empty
                            UserDefaults.standard.set(m.wrappedValue.id, forKey: "myId")
                            UserDefaults.standard.set(m.wrappedValue.home, forKey: "houseId")
                            inWR.wrappedValue = true
                            print("\n\n\n\n\(mm)\n\n\n\n")
                        } else {
                            
                            self.db.collection("houses/\(house)/members/").getDocuments { querySnapshot, err in
                                guard let docs = querySnapshot?.documents else {
                                    print(err.debugDescription)
                                    return
                                }
                                if !docs.contains(where: { doc in
                                    let data = doc.data()
                                    let name = data["name"] ?? ""
                                    return name as! String == m.wrappedValue.name
                                    
                                }) || forceAdmin {
                                    //
                                    self.db.document("houses/\(house)/members/\("\(mm.id)")").setData(["name" : mm.name, "image" : mm.image, "home" : h.documentID, "admin": forceAdmin, "showStatus": mm.showStatus]) { _ in
                                        hh.wrappedValue.members.append(m.wrappedValue)
                                        self.getHouse(h: hh, inWR: inWR, noProf: .constant(false))
                                        UserDefaults.standard.set(mm.id, forKey: "myId")
                                        UserDefaults.standard.set(h.documentID, forKey: "houseId")
                                        inWR.wrappedValue = false
                                        if deleteFromHere != "" {
                                            var mem = Member.empty
                                            mem.id = mm.id
                                            mem.home = startHouseID
                                            self.deleteAccount(m: .constant(mem), erase: true, inWR: .constant(false), transfer: true)
                                        } else {
                                            self.db.document("waitingRoom/\(mm.id)").delete()
                                        }
                                        self.sendPayment(p: Payment(from: mm.name, time: Int(NSDate().timeIntervalSince1970), memo: "\(forceAdmin ? "created" : "joined") the group", isAn: true), h: House(id: h.documentID, name: "", members: [Member](), payments: [Payment](), password: ""))
                                        if killHouse {
//                                            self.db.document("houses/\(h.documentID)").delete()
                                        }
                                    }
                                    //
                                    
                                } else {
                                    showAlert.wrappedValue = true
                                    tapped.wrappedValue = false
                                    msg.wrappedValue = "Member already exists by that name"
                                }
                                
                            }
                            
                            
                        }
                    } else {
                        showAlert.wrappedValue = true
                        tapped.wrappedValue = false
                        msg.wrappedValue = "Incorrect password"
                    }
                    
                }
            }
            if house == House.empty.id {
                showAlert.wrappedValue = true
                tapped.wrappedValue = false
                msg.wrappedValue = "Group not found"
            }
            tapped.wrappedValue = false
        }
    }
    
    func createHouse(hh: Binding<House>, m: Binding<Member>, name: String, password: String, tapped: Binding<Bool>, inWR: Binding<Bool>) {
        let id = db.collection("houses").addDocument(data: ["name" : name, "password" : password]).documentID
        m.wrappedValue.home = id
        m.wrappedValue.admin = true
        hh.wrappedValue.members = [m.wrappedValue]
        //        db.collection("houses/\(id)/members").addDocument(data: ["admin" : true, "name" : m.wrappedValue.name, "home" : id, "image" : m.wrappedValue.id]) { (err) in
        UserDefaults.standard.set(m.wrappedValue.id, forKey: "myId")
        UserDefaults.standard.set(id, forKey: "houseId")
        self.joinHouse(hh: hh, m: m, hId: id, password: password, showAlert: .constant(false), tapped: .constant(true), msg: .constant(""), inWR: inWR, forceAdmin: true)
        //        }
    }
    
    func deleteAccount(m: Binding<Member>, erase: Bool = false, inWR: Binding<Bool>, transfer: Bool = false) {
        if m.wrappedValue.home != "" {
            self.db.collection("houses/\(m.wrappedValue.home)/payments").getDocuments { (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("remove member no payments or something")
                    return
                }
                
                self.db.collection("houses/\(m.wrappedValue.home)/members").getDocuments { qs, err in
                    guard (qs?.count) != nil else {
                        return
                    }
                    if erase {
                        for doc in documents {
                            self.db.document("houses/\(m.wrappedValue.home)/payments/\(doc.documentID)").delete()
                        }
                    } else {
                        for doc in documents.filter({ (doc) -> Bool in
                            let d = doc.data()
                            let to = (d["to"] ?? "") as! String
                            let from = (d["from"] ?? "") as! String
                            let reqfrom = (d["reqfrom"] ?? [""]) as! [String]
                            let isAn = d["isAn"] as? Bool ?? false
                            return (to.contains(m.wrappedValue.name) || from.contains(m.wrappedValue.name) || reqfrom.contains(m.wrappedValue.name)) && !isAn
                        }) {
                            self.db.document("houses/\(m.wrappedValue.home)/payments/\(doc.documentID)").delete()
                        }
                    }
                    
                }
                
            }
            db.document("houses/\(m.wrappedValue.home)/members/\(m.wrappedValue.id)").delete { (err) in
                if erase {
                    self.db.document("houses/\(m.wrappedValue.home)").delete()
                } else {
                    self.sendPayment(p: Payment(from: m.wrappedValue.name, time: Int(NSDate().timeIntervalSince1970), memo: "left the group", isAn: true), h: House(id: m.wrappedValue.home, name: "", members: [Member](), payments: [Payment](), password: ""))
                }
                if !transfer {
                    m.wrappedValue = .empty
                    UserDefaults.standard.set(m.wrappedValue.id, forKey: "myId")
                    UserDefaults.standard.set(m.wrappedValue.home, forKey: "houseId")
                    inWR.wrappedValue = true
                    m.wrappedValue.id = ""
                }
                
            }
        }
    }
    
    func placeToken(h: Binding<House>, id: String, token: String) {
        db.document("houses/\(h.wrappedValue.id)/members/\(id)").updateData(["fcm" : token])
    }
    
    func updateStatus(status: Bool) {
        let id = UserDefaults.standard.string(forKey: "houseId") ?? ""
        let myId = UserDefaults.standard.string(forKey: "myId") ?? ""
        print("Status: \(id) \(myId)")
        db.document("houses/\(id)/members/\(myId)/").updateData(["online":status, "lastSeen":NSDate().timeIntervalSince1970])
    }
    
    func toggleShowStatus(s: Bool) {
        let id = UserDefaults.standard.string(forKey: "houseId") ?? ""
        let myId = UserDefaults.standard.string(forKey: "myId") ?? ""
        print("Status: \(id) \(myId)")
        db.document("houses/\(id)/members/\(myId)/").updateData(["showStatus":s])
    }
    
    func groupNameFromId(id: String, nn: Binding<String>) {
        db.document("houses/\(id)").getDocument { docSnap, err in
            guard let doc = docSnap?.get("name") else {
                nn.wrappedValue = "err"
                return
            }
            nn.wrappedValue = doc as! String
        }
    }
    
    func returnMembers(hId: String, nm: Binding<[Member]>, msg: Binding<String>, showAlert: Binding<Bool>) {
        db.collection("houses/\(hId)/members").getDocuments { querySnapshot, err in
            guard let docs = querySnapshot?.documents else {
                print(err.debugDescription)
                return
            }
            nm.wrappedValue = docs.map({ q in
                let data = q.data()
                
                let name = data["name"] as? String ?? ""
                let home = data["home"] as? String ?? ""
//                let owesMe = data["owesMe"] as? [String : Float] ?? [String : Float]()
//                let iOwe = data["iOwe"] as? [String : Float] ?? [String : Float]()
                let image = data["image"] as? String ?? ""
                let admin = data["admin"] as? Bool ?? false
//                let showStatus = data["showStatus"] as? Bool ?? false
//                let online = data["online"] as? Bool ?? false
//                let lastSeen = data["lastSeen"] as? NSNumber ?? 0

                return Member(id: q.documentID, home: home, name: name, owesMe: [:], iOwe: [:], image: image, admin: admin, showStatus: false)
            })
        }
    }
    
    func checkKicked(h: House, m: Member, _ completion: @escaping (Bool) -> EmptyView) -> EmptyView {
        print("CHECKKICKED \(h.id) <- hid")
        self.db.collection("houses/\(h.id)/payments").getDocuments { querySnapshot, err in
            guard let docs = querySnapshot?.documents else {
                print("noPaymentsSoKicked")
                completion(true)
                return
            }
            var started = false
            docs.forEach { queryDocumentSnapshot in
                started = true
                let d = queryDocumentSnapshot.data()
                let from = d["from"] as? String ?? ""
                let memo = d["memo"] as? String ?? ""
                
                if from == m.name && memo == "was removed from the group" {
                    print("REDHANDED")
                    completion(true)
                }
                
            }
            if started {
                print("DIDNTFINDITSOJUSTINVITE")
                completion(false)
            }
        }
        return EmptyView()
    }
    
}

func idfromnamehouse(name: String, house: House) -> String {
    return house.members.first { (m) -> Bool in
        return m.name == name
    }?.id ?? ""
}
